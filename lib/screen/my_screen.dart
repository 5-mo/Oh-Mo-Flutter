import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ohmo/const/colors.dart';
import 'package:ohmo/customize_category.dart';
import 'package:ohmo/screen/login/login_screen.dart';
import 'package:ohmo/screen/profile_screen.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:ohmo/services/member_service.dart';
import 'package:provider/provider.dart';
import 'package:ohmo/models/profile_data_provider.dart';
import 'package:ohmo/screen/category_screen.dart';
import 'package:ohmo/screen/diary_collection_screen.dart';
import '../db/drift_database.dart' as db;
import 'etc_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MyScreen extends StatefulWidget {
  final Function(int) onTabChange;
  final ValueNotifier<DateTime> selectedDateNotifier;
  final VoidCallback? onDataChanged;

  MyScreen({
    required this.onTabChange,
    required this.selectedDateNotifier,
    this.onDataChanged,
  });

  @override
  _MyScreenState createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  bool _showSearchRecords = false;
  bool _isDiaryVisible = true;
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  final MemberService _memberService = MemberService();

  final TextEditingController _searchController = TextEditingController();

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _showSearchRecords = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _showSearchRecords = true;
    });

    final database = db.LocalDatabaseSingleton.instance;

    List<Map<String, dynamic>> results = await database.searchSchedules(query);

    if (mounted) {
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadVisibilitySettings();
    _loadUserInfo();
  }

  Future<void> _loadVisibilitySettings() async {
    final isDiaryVisible = await DiaryVisibilityHelper.getVisibility();
    if (mounted) {
      setState(() {
        _isDiaryVisible = isDiaryVisible;
      });
    }
  }

  Future<void> _goToProfileEdit(BuildContext context) async {
    final profile = Provider.of<ProfileData>(context, listen: false);
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder:
            (context) => ProfileScreen(
              initialImage: profile.image,
              initialNickname: profile.nickname,
              initialEmail: profile.email,
            ),
      ),
    );

    if (result != null) {
      profile.updateProfile(
        updateImage: result['image'],
        updateNickname: result['nickname'],
        updateEmail: result['email'],
      );
    }
  }

  Future<void> _loadUserInfo() async {
    final result = await _memberService.fetchUserInfo();

    if (result != null) {
      if (mounted) {
        Provider.of<ProfileData>(context, listen: false).updateFromApi(result);
      }
    } else {
      print("사용자 정보를 불러오지 못했습니다.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileData>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          setState(() {
            _showSearchRecords = false;
          });
        },
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned(
                    child: SvgPicture.asset(
                      'android/assets/images/mybackground.svg',
                      width: double.infinity,
                      alignment: Alignment.topCenter,
                    ),
                  ),

                  Positioned(
                    top: 66,
                    left: 41,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap:
                              profile.isGuest
                                  ? null
                                  : () => _goToProfileEdit(context),
                          child:
                              profile.image != null
                                  ? ClipOval(
                                    child: Image.file(
                                      profile.image!,
                                      width: 84,
                                      height: 84,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                  : (profile.imageUrl != null &&
                                      profile.imageUrl!.isNotEmpty)
                                  ? ClipOval(
                                    child: Image.network(
                                      profile.imageUrl!,
                                      width: 84,
                                      height: 84,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (
                                            context,
                                            error,
                                            stackTrace,
                                          ) => SvgPicture.asset(
                                            'android/assets/images/myprofile.svg',
                                          ),
                                    ),
                                  )
                                  : SvgPicture.asset(
                                    'android/assets/images/myprofile.svg',
                                  ),
                        ),

                        SizedBox(width: 50),
                        _buildProfileSection(context),
                      ],
                    ),
                  ),

                  Positioned(
                    left: 38,
                    top: 367,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildNotionButton(context),
                        SizedBox(height: 20.0),
                        _buildCategoryManaging(context),
                        if (_isDiaryVisible) ...[
                          SizedBox(height: 15.0),
                          _buildDiaryCollection(context),
                        ],
                        SizedBox(height: 15.0),
                        _buildEtc(context),
                      ],
                    ),
                  ),

                  Positioned(
                    left: 50,
                    top: 186,

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSearchbarSection(context),
                        _buildSearchbarRecords(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    final profile = Provider.of<ProfileData>(context);
    return Column(
      children: [
        Text(
          profile.isGuest ? "GUEST" : profile.nickname,
          style: TextStyle(color: Colors.white, fontSize: 16.0),
        ),
        if (!profile.isGuest)
          Text(
            profile.email,
            style: TextStyle(color: Colors.white, fontSize: 16.0),
          ),
        SizedBox(height: 10.0),
        _buildProfileButton(context),
      ],
    );
  }

  Widget _buildProfileButton(BuildContext context) {
    final profile = Provider.of<ProfileData>(context, listen: false);
    return GestureDetector(
      onTap: () async {
        if (profile.isGuest) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        } else {
          final result = await Navigator.push<Map<String, dynamic>>(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ProfileScreen(
                    initialImage: profile.image,
                    initialNickname: profile.nickname,
                    initialEmail: profile.email,
                  ),
            ),
          );
          if (result != null) {
            profile.updateProfile(
              updateImage: result?['image'],
              updateNickname: result?['nickname'],
              updateEmail: result?['email'],
            );
          }
        }
      },
      child: Container(
        width: 87,
        height: 18,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white),
        ),

        child: Center(
          child: Text(
            profile.isGuest ? '로그인해주세요' : '프로필 수정',
            style: TextStyle(
              fontSize: 10,
              fontFamily: 'PretendardRegular',
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchbarSection(BuildContext context) {
    return Container(
      height: 31,
      width: 311,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white),
      ),

      child: Row(
        children: [
          SizedBox(width: 40.0),
          Expanded(
            child: TextField(
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'PretendardRegular',
              ),
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '일정 검색',
                hintStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'PretendardRegular',
                ),
                border: InputBorder.none,
              ),
              textAlign: TextAlign.center,
              onTap: () {
                setState(() {
                  _showSearchRecords = true;
                });
              },

              onChanged: (text) {
                _performSearch(text);
              },
            ),
          ),

          GestureDetector(
            onTap: () {},
            child: Icon(Icons.search, color: Colors.white),
          ),
          SizedBox(width: 10.0),
        ],
      ),
    );
  }

  Widget _buildSearchbarRecords(BuildContext context) {
    return Visibility(
      visible: _showSearchRecords,
      child: Container(
        width: 311,
        constraints: BoxConstraints(maxHeight: 400),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Middle_GREY_COLOR),
        ),
        child:
            _isLoading
                ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
                : _searchResults.isEmpty
                ? Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    '검색 결과가 없습니다.',
                    style: TextStyle(color: DARK_GREY_COLOR),
                  ),
                )
                : ListView.separated(
                  padding: EdgeInsets.symmetric(vertical: 4.0),
                  shrinkWrap: true,
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final record = _searchResults[index];
                    final date = record['date'] as DateTime;
                    return InkWell(
                      onTap: () {
                        widget.selectedDateNotifier.value = date;
                        widget.onTabChange(1);
                        setState(() {
                          _showSearchRecords = false;
                          _searchController.clear();
                          FocusScope.of(context).unfocus();
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 6.0,
                          horizontal: 12.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              record['content'] as String,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              DateFormat('yyyy.MM.dd').format(date),
                              style: TextStyle(
                                fontSize: 13,
                                color: Middle_GREY_COLOR,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder:
                      (context, index) =>
                          Divider(color: Colors.grey[300], height: 1),
                ),
      ),
    );
  }

  Future<void> _testNotionIntegration() async {
    const String notionToken =
        'ntn_S4139943297a3lp7jr2q8STxcy5IhFSH4j6RtOGsfz86xv';
    const String databaseId = '7cb0f6c28581838fab3a8182f1f54a1a';

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('노션으로 데이터를 전송 중입니다...'),
        duration: Duration(seconds: 1),
      ),
    );

    try {
      final url = Uri.parse('https://api.notion.com/v1/pages');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $notionToken',
          'Notion-Version': '2022-06-28',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'parent': {'database_id': databaseId},
          'properties': {
            'content': {
              'rich_text': [
                {
                  'text': {'content': '오모에서 보낸 테스트 일정! 🚀'},
                },
              ],
            },
          },
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ 노션 연동 성공! 표를 확인해보세요.')),
          );
        }
      } else {
        print('❌ 실패 상세: ${response.body}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ 연동 실패: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      print('❌ 에러: $e');
    }
  }

  Widget _buildNotionButton(BuildContext context) {
    return GestureDetector(
      // GestureDetector 추가
      onTap: _testNotionIntegration,
      child: Container(
        width: 311,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.white,
          borderRadius: BorderRadius.circular(9),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
          ],
        ),
        child: Center(
          child: Row(
            children: [
              const SizedBox(width: 20.0),
              SvgPicture.asset('android/assets/images/notion.svg'),
              const SizedBox(width: 30.0),
              const Text(
                'Notion 연결 및 업데이트',
                style: TextStyle(fontSize: 18, fontFamily: 'PretendardRegular'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateDiaryVisibility() async {
    final isVisible = await DiaryVisibilityHelper.getVisibility();
    setState(() {
      _isDiaryVisible = isVisible;
    });
  }

  Widget _buildCategoryManaging(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final bool? result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (context) => CategoryScreen()),
        );
        if (!mounted) return;
        _updateDiaryVisibility();
        if (result == true) {
          if (widget.onDataChanged != null) {
            widget.onDataChanged!();
          }
        }
      },
      child: Text(
        '카테고리 관리',
        style: TextStyle(fontSize: 18, fontFamily: 'PretendardBold'),
      ),
    );
  }

  Widget _buildDiaryCollection(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => DiaryCollectionScreen(
                  selectedDateNotifier: widget.selectedDateNotifier,
                  onTabChange: widget.onTabChange,
                ),
          ),
        );
      },
      child: Text(
        '일기 모아보기',
        style: TextStyle(fontSize: 18, fontFamily: 'PretendardBold'),
      ),
    );
  }

  Widget _buildEtc(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EtcScreen()),
        );
      },
      child: Text(
        '기타',
        style: TextStyle(fontSize: 18, fontFamily: 'PretendardBold'),
      ),
    );
  }
}
