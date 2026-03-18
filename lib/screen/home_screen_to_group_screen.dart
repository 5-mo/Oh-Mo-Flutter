import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ohmo/component/delete_popup.dart';
import 'package:ohmo/const/colors.dart';
import 'package:ohmo/db/local_category_repository.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:ohmo/models/profile_data_provider.dart';
import 'package:ohmo/screen/group/group_main_screen.dart';
import 'package:ohmo/services/group_service.dart';
import 'package:provider/provider.dart';
import '../component/color_palette_bottom_sheet.dart';
import '../component/group_settings_bottom_sheet.dart';
import '../customize_category.dart';
import 'package:uuid/uuid.dart';
import 'package:ohmo/db/drift_database.dart'
    show LocalDatabase, LocalDatabaseSingleton, Group;
import 'package:ohmo/services/category_service.dart';
import 'group/group_sign_screen.dart';

class HomeScreenToGroupScreen extends StatefulWidget {
  const HomeScreenToGroupScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenToGroupScreenState createState() =>
      _HomeScreenToGroupScreenState();
}

class _HomeScreenToGroupScreenState extends State<HomeScreenToGroupScreen> {
  bool _needsRefresh = false;
  final GlobalKey<ExpansionTileCardState> _groupTileKey = GlobalKey();
  bool _isGroupDeleted = false;

  ColorType _selectedColorType = ColorType.pinkLight;

  late LocalCategoryRepository _repository;
  late LocalDatabase _db;

  final uuid = Uuid();
  final CategoryService _categoryService = CategoryService();
  final GroupService _groupService = GroupService();
  List<dynamic> _groups = [];

  @override
  void initState() {
    super.initState();
    _db = LocalDatabaseSingleton.instance;
    _repository = LocalCategoryRepository(_db);
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    final fetchedGroups = await _groupService.fetchGroups();

    final List<Map<String, dynamic>> groupWithMembers = await Future.wait(
      fetchedGroups.map((group) async {
        final int groupId = group['groupId'];
        final memberData = await _groupService.fetchGroupMembers(groupId);
        final localGroup = await _db.getGroupById(groupId);

        final String finalColorType =
            localGroup?.localColor ?? group['groupColor'] ?? 'pinkLight';

        final List<dynamic> members =
            memberData != null
                ? (memberData['memberGroupInfos'] ??
                    memberData['memberDtoList'] ??
                    [])
                : [];

        final myEmail = await _groupService.getMyEmail();

        final myInfo = members.firstWhere(
          (m) => m['memberInfo']['email'] == myEmail,
          orElse: () => null,
        );

        return {
          ...group,
          'groupColor': finalColorType,
          'members': members,
          'myRole': myInfo?['role'],
          'totalCount': memberData != null ? memberData['numPeople'] : 0,
        };
      }),
    );

    final isGroupVisible = await GroupVisibilityHelper.getVisibility();

    if (mounted) {
      setState(() {
        _groups = groupWithMembers;
        _isGroupDeleted = !isGroupVisible;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (context.mounted) {
          Navigator.pop(context, _needsRefresh);
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          surfaceTintColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: () {
              Navigator.pop(context, _needsRefresh);
            },
          ),
          backgroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 31),
                child: _buildGroupAccordion(),
              ),

              SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupSection({required dynamic group,required double width}) {
    final String name = group['groupName'] ?? '이름 없음';
    final int groupId = group['groupId'] ?? 0;
    final String colorTypeString = group['groupColor'] ?? 'pinkLight';
    final Color color = ColorManager.getColor(
      ColorTypeExtension.fromString(colorTypeString),
    );
    final List<dynamic> members = group['members'] ?? [];
    final myInfo = members.firstWhere(
      (m) => m['memberInfo']['email'] == "",
      orElse: () => null,
    );
    final int totalCount = group['totalCount'] ?? members.length;
    return InkWell(
      onTap: () async {
        if (groupId == null) {
          print("에러: groupId가 비어있습니다.");
          return;
        }
        final bool? needsRefresh = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => GroupMainScreen(groupId: groupId),
          ),
        );
        if (needsRefresh == true) {
          _loadAllData();
        }
      },
      child: Container(
        width: width,
        height: 111,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.4),
              spreadRadius: 1,
              blurRadius: 1,
            ),
          ],
        ),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: width-10,
                  height: 70,
                  margin: const EdgeInsets.only(top: 5),
                  padding: const EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.4),
                        spreadRadius: 1,
                        blurRadius: 1,
                      ),
                    ],
                  ),
                  child: Text(
                    name.replaceAll(' ', '\n'),
                    style: TextStyle(
                      fontFamily: 'PretendardMedium',
                      fontSize: 12,
                      color: const Color(0xFF000000),
                    ),
                  ),
                ),
                Positioned(
                  top: 17,
                  right: 7,
                  child: GestureDetector(
                    onTap: () async {
                      final String? currentRole = group['myRole'];
                      final bool? needsRefresh =
                          await showModalBottomSheet<bool>(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(59),
                                topLeft: Radius.circular(59),
                              ),
                            ),
                            builder: (BuildContext bContext) {
                              return GroupSettingsBottomSheet(
                                groupId: groupId,
                                groupName: name,
                                initialRole: currentRole,
                                onColorChanged: (ColorType newColor) {
                                  _loadAllData();
                                },
                              );
                            },
                          );
                      if (needsRefresh == true) {
                        _loadAllData();
                      }
                    },
                    child: Container(
                      color: Colors.transparent,
                      padding: const EdgeInsets.all(8.0),
                      child: SvgPicture.asset(
                        'android/assets/images/todo_alarm.svg',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ...members.take(6).map((member) {
                    final memberInfo = member['memberInfo'] ?? {};
                    final String? profileUrl = memberInfo['profileImageUrl'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: _buildMemberProfile(profileUrl, 0.2, color),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateGroupCard() {
    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GroupSignScreen()),
        );
        _loadAllData();
      },
      child: Container(
        width: 150,
        height: 111,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.4),
              spreadRadius: 1,
              blurRadius: 1,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 140,
              height: 70,
              margin: const EdgeInsets.only(top: 5),
              padding: const EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.4),
                    spreadRadius: 1,
                    blurRadius: 1,
                  ),
                ],
              ),
              child: Text(
                '그룹\n만들기',
                style: TextStyle(
                  fontFamily: 'PretendardMedium',
                  fontSize: 12,
                  color: const Color(0xFF7B7B7B),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 9, horizontal: 8),
                child: Icon(Icons.add, size: 17, color: Color(0xFF7B7B7B)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberProfile(
    String? imageUrl,
    double progress,
    Color groupColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 3,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: 8,
            backgroundColor: Colors.grey[200],
            backgroundImage:
                (imageUrl != null &&
                        imageUrl.isNotEmpty &&
                        imageUrl.startsWith('http'))
                    ? NetworkImage(imageUrl)
                    : const AssetImage('android/assets/images/clear_ohmo.png')
                        as ImageProvider,
          ),
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 3,
              backgroundColor: Color(0xFFA5A5A5),
              valueColor: AlwaysStoppedAnimation<Color>(groupColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupAccordion() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxHeight - 31;
        final double spacing = 16.0;
        final double cardWidth = (availableWidth - spacing) / 2;

        return Padding(
          padding: const EdgeInsets.only(right: 31),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Group',
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: 'RubikSprayPaint',
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add_circle, color: Colors.black),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GroupSignScreen(),
                          ),
                        );
                        _loadAllData();
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Divider(color: Colors.black),
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Wrap(
                  spacing: spacing,
                  runSpacing: 23.0,
                  alignment: WrapAlignment.start,
                  children: [
                    ..._groups.map((group) {
                      return _buildGroupSection(group: group, width: 145);
                    }).toList(),
                    if (_groups.isEmpty) _buildCreateGroupCard(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openColorPicker(
    BuildContext context, {
    int? categoryId,
    String? currentName,
  }) async {
    final ColorType? selected = await showModalBottomSheet<ColorType>(
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

    if (selected != null && categoryId != null && currentName != null) {
      final profile = Provider.of<ProfileData>(context, listen: false);

      if (!profile.isGuest) {
        await _categoryService.updateCategory(
          categoryId: categoryId,
          categoryName: currentName,
          color: selected.name,
        );
      }

      await _repository.updateCategoryColor(categoryId, selected.name);

      _loadAllData();
      setState(() => _needsRefresh = true);
    }
  }
}
