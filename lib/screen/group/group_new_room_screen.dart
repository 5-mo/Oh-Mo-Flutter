import 'package:flutter/material.dart';
import 'package:ohmo/const/colors.dart';
import '../../component/color_palette_bottom_sheet.dart';
import 'package:flutter/services.dart';

import 'group_add_member_screen.dart';

class GroupNewRoomScreen extends StatefulWidget {
  const GroupNewRoomScreen({Key? key}) : super(key: key);

  @override
  _GroupNewRoomScreenState createState() => _GroupNewRoomScreenState();
}

class _GroupNewRoomScreenState extends State<GroupNewRoomScreen> {
  ColorType _selectedColorType = ColorType.values[0];
  final TextEditingController _roomnameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  int _selectedMemberCount = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 30.0),
            _buildNewRoomHeader(),
            SizedBox(height: 15.0),
            _buildRoomColor(),
            SizedBox(height: 18.0),
            _buildNameTextField(_roomnameController),
            SizedBox(height: 55.0),
            _buildMemberNumbers(),
            SizedBox(height: 55.0),
            _buildRoomPassword(_passwordController),
            SizedBox(height: 55.0),
            _buildSaveButton()
          ],
        ),
      ),
    );
  }

  Widget _buildNewRoomHeader() {
    return Center(
      child: Column(
        children: [
          Text(
            '새로운 방 만들기',
            style: TextStyle(fontFamily: 'PretendardBold', fontSize: 20.0),
          ),
          SizedBox(height: 20),
          Text(
            '어떤 목적의 그룹인가요?\n그룹방의 배경색도 골라주세요',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'PretendardMedium', fontSize: 13.0),
          ),
          Text(
            '이후 변경 가능합니다',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'PretendardMedium',
              fontSize: 11.0,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomColor() {
    return GestureDetector(
      onTap: _openColorPicker,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 7),
              ],
            ),
          ),
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: ColorManager.getColor(_selectedColorType),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameTextField(TextEditingController controller) {
    return Container(
      width: 168,
      height: 43,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),

        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 3),
        ],
      ),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,

          prefixIcon:
              controller.text.isNotEmpty
                  ? IconButton(
                    icon: Icon(
                      Icons.cancel,
                      color: Colors.transparent,
                      size: 14,
                    ),
                    onPressed: null,
                  )
                  : null,

          suffixIcon:
              controller.text.isNotEmpty
                  ? IconButton(
                    icon: Icon(Icons.cancel, color: ICON_GREY_COLOR, size: 14),
                    onPressed: () {
                      setState(() {
                        controller.clear();
                      });
                    },
                  )
                  : null,
        ),
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  Widget _buildMemberNumbers() {
    final int _maxMembers = 6;

    return Center(
      child: Column(
        children: [
          Text(
            '그룹 멤버 인원수를 설정하세요',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'PretendardMedium', fontSize: 13.0),
          ),
          Text(
            '이후 변경 가능합니다',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'PretendardMedium',
              fontSize: 11.0,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_maxMembers, (index) {
              final int memberNumber = index + 1;

              final bool isSelected = memberNumber <= _selectedMemberCount;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMemberCount = memberNumber;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: Image.asset(
                    'android/assets/images/clear_ohmo.png',
                    width: 28,
                    color: isSelected ? Colors.black : Colors.grey,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomPassword(TextEditingController controller) {
    return Column(
      children: [
        Text(
          '잠금 비밀번호를 설정하세요',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'PretendardMedium', fontSize: 13.0),
        ),
        Text(
          '최대 4자리 숫자',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'PretendardMedium',
            fontSize: 11.0,
            color: Colors.grey,
          ),
        ),
        SizedBox(height: 10),
        Container(
          width: 168,
          height: 43,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(9),

            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 3),
            ],
          ),
          child: TextField(
            controller: controller,
            textAlign: TextAlign.center,
            inputFormatters: [
              LengthLimitingTextInputFormatter(4),
            ],
            decoration: InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,

              prefixIcon:
                  controller.text.isNotEmpty
                      ? IconButton(
                        icon: Icon(
                          Icons.cancel,
                          color: Colors.transparent,
                          size: 14,
                        ),
                        onPressed: null,
                      )
                      : null,

              suffixIcon:
                  controller.text.isNotEmpty
                      ? IconButton(
                        icon: Icon(
                          Icons.cancel,
                          color: ICON_GREY_COLOR,
                          size: 14,
                        ),
                        onPressed: () {
                          setState(() {
                            controller.clear();
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
      ],
    );
  }

  Widget _buildSaveButton() {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GroupAddMemberScreen()),
          );
        },
        child: Container(
          width: 327,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Center(
            child: Text(
              '확인',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'PretendardBold',
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openColorPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(59),
          topRight: Radius.circular(59),
        ),
      ),
      builder:
          (context) => ColorPaletteBottomSheet(
            selectedColorType: _selectedColorType,
            onColorSelected: (colorType) {
              setState(() {
                _selectedColorType = colorType;
              });
            },
          ),
    );
  }
}
