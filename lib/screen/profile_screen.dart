import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:ohmo/screen/password/password_screen.dart';
import 'package:provider/provider.dart';
import 'package:ohmo/models/profile_data_provider.dart';

import '../services/member_service.dart';

class ProfileScreen extends StatefulWidget {
  final File? initialImage;
  final String? initialNickname;
  final String? initialEmail;

  const ProfileScreen({
    Key? key,
    this.initialImage,
    this.initialNickname,
    this.initialEmail,
  }) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _image;
  final TextEditingController _nicknameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<ProfileData>(context, listen: false);
    _image = profile.image;
    _nicknameController.text = profile.nickname;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        print('압축된 이미지 경로: ${_image!.path}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },

          child: Text(
            '취소',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'PretendardBold',
              fontSize: 16,
            ),
          ),
        ),

        actions: <Widget>[
          TextButton(
            onPressed:
                _isLoading
                    ? null
                    : () async {
                      setState(() => _isLoading = true);
                      String newNickname = _nicknameController.text;

                      MemberService memberService = MemberService();
                      bool isSuccess = true;

                      isSuccess = await memberService.updateNickname(
                        _nicknameController.text,
                      );

                      await Future.delayed(Duration(milliseconds: 500));

                      if (isSuccess && _image != null) {
                        isSuccess = await memberService.updateProfileImage(
                          _image!,
                        );
                      }
                      if (isSuccess) {
                        Provider.of<ProfileData>(
                          context,
                          listen: false,
                        ).updateProfile(
                          updateImage: _image,
                          updateNickname: newNickname,
                        );

                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('닉네임 수정에 실패했습니다. 다시 시도해주세요.')),
                        );
                      }
                      setState(() => _isLoading = false);
                    },
            child: Text(
              '완료',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'PretendardBold',
                fontSize: 16,
              ),
            ),
          ),
        ],

        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned(
            child: SvgPicture.asset(
              'android/assets/images/background_edit.svg',
              width: double.infinity,
              alignment: Alignment.topCenter,
            ),
          ),
          Positioned(
            top: 71,
            left: 150,
            child: GestureDetector(
              onTap: _pickImage,
              child: Consumer<ProfileData>(
                builder: (context, profile, child) {
                  if (_image != null) {
                    return ClipOval(
                      child: Image.file(
                        _image!,
                        width: 103,
                        height: 103,
                        fit: BoxFit.cover,
                      ),
                    );
                  } else if (profile.imageUrl != null &&
                      profile.imageUrl!.isNotEmpty) {
                    return ClipOval(
                      child: Image.network(
                        profile.imageUrl!,
                        width: 103,
                        height: 103,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => SvgPicture.asset(
                              'android/assets/images/profile_photo.svg',
                            ),
                      ),
                    );
                  } else {
                    return SvgPicture.asset(
                      'android/assets/images/profile_photo.svg',
                    );
                  }
                },
              ),
            ),
          ),

          Positioned(
            top: 217,
            left: 38,
            child: Column(
              children: [
                _buildNickname(context),
                SizedBox(height: 20.0),
                _buildPassword(context),
                SizedBox(height: 20.0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNickname(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '닉네임',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontFamily: 'PretendardBold',
          ),
        ),

        Container(
          width: 320,
          child: TextField(
            controller: _nicknameController,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontFamily: 'PretendardRegular',
            ),

            decoration: InputDecoration(
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),

              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 2.0),
              ),

              suffixIcon:
                  _nicknameController.text.isNotEmpty
                      ? IconButton(
                        icon: Icon(Icons.cancel, color: Colors.grey, size: 14),

                        onPressed: () {
                          setState(() {
                            _nicknameController.clear();
                          });
                        },
                      )
                      : null,
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),
        SizedBox(height: 10.0),
      ],
    );
  }

  Widget _buildPassword(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PasswordScreen()),
        );
      },

      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.only(left: 0),
          child: Text(
            ' 비밀번호 재설정                                                 >      ',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'PretendardBold',
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
