import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/cupertino.dart';
import 'package:ohmo/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlarmSettingScreen extends StatefulWidget {
  const AlarmSettingScreen({super.key});

  @override
  State<AlarmSettingScreen> createState() => _AlarmSettingScreenState();
}

class _AlarmSettingScreenState extends State<AlarmSettingScreen> {
  bool isAllChecked = false;
  bool isGroupRoutineChecked = false;
  bool isGroupTodoChecked = false;
  bool isGroupNoticeChecked = false;
  bool isCalendarChecked = false;
  bool isInvitationChecked = false;
  bool isServiceChecked = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isAllChecked = prefs.getBool('all_noti') ?? true;
      isGroupRoutineChecked = prefs.getBool('group_routine_noti') ?? true;
      isGroupTodoChecked = prefs.getBool('group_todo_noti') ?? true;
      isGroupNoticeChecked = prefs.getBool('group_notice_noti') ?? true;
      isCalendarChecked = prefs.getBool('calendar_noti') ?? true;
      isInvitationChecked = prefs.getBool('invitation_noti') ?? true;
      isServiceChecked = prefs.getBool('service_noti') ?? true;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            'android/assets/images/left.svg',
            width: 21,
            height: 21,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: const Text(
          '알림 설정                                                                        ',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'PretendardRegular',
            fontSize: 14,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildInformationBox(context),
            const SizedBox(height: 20),
            _buildBaseCard(
              children: [
                _buildSwitchRow(
                  title: '전체 알림',
                  subtitle: '모든 알림을 받습니다',
                  value: isAllChecked,
                  onChanged: (value) async {
                    setState(() {
                      isAllChecked = value!;
                      isGroupRoutineChecked =
                          isGroupTodoChecked =
                              isGroupNoticeChecked =
                                  isCalendarChecked =
                                      isInvitationChecked =
                                          isServiceChecked = value;
                      if (!value) {
                        NotificationService().cancelAllNotifications();
                      } else {
                        print("모든 알림 설정이 활성화되었습니다.");
                      }
                    });
                    await _saveSetting('all_noti', value);
                    _saveAllSubSettings(value);
                  },
                ),
              ],
            ),

            _buildBaseCard(
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '그룹 알림',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'PretendardRegular',
                      color: Color(0xFF0A0A0A),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                _buildSwitchRow(
                  title: '루틴 등록 알림',
                  subtitle: '그룹에 새로운 루틴이 등록되면 알림을 받습니다',
                  value: isGroupRoutineChecked,
                  onChanged:
                      !isAllChecked
                          ? null
                          : (val) {
                            setState(() => isGroupRoutineChecked = val);
                            _saveSetting('group_routine_noti', val);
                          },
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFF3F4F6)),
                const SizedBox(height: 16),
                _buildSwitchRow(
                  title: '할 일 등록 알림',
                  subtitle: '그룹에 새로운 할 일이 등록되면 알림을 받습니다',
                  value: isGroupTodoChecked,
                  onChanged:
                      !isAllChecked
                          ? null
                          : (val) {
                            setState(() => isGroupTodoChecked = val);
                            _saveSetting('group_todo_noti', val);
                          },
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFF3F4F6)),
                const SizedBox(height: 16),
                _buildSwitchRow(
                  title: '공지 등록 알림',
                  subtitle: '그룹에 새로운 공지가 등록되면 알림을 받습니다',
                  value: isGroupNoticeChecked,
                  onChanged:
                      !isAllChecked
                          ? null
                          : (val) {
                            setState(() => isGroupNoticeChecked = val);
                            _saveSetting('group_notice_noti', val);
                          },
                ),
              ],
            ),
            _buildBaseCard(
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '캘린더 알림',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'PretendardRegular',
                      color: Color(0xFF0A0A0A),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                _buildSwitchRow(
                  title: '일정 알림',
                  subtitle: '등록된 일정 시간에 알림을 받습니다',
                  value: isCalendarChecked,
                  onChanged:
                      !isAllChecked
                          ? null
                          : (val) async {
                            setState(() => isCalendarChecked = val);
                            await _saveSetting('calendar_noti', val);
                            if (!val) {
                              await NotificationService()
                                  .cancelPersonalCalendarNotifications();
                            }
                          },
                ),
              ],
            ),
            _buildBaseCard(
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '기타 알림',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'PretendardRegular',
                      color: Color(0xFF0A0A0A),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                _buildSwitchRow(
                  title: '그룹 초대 알림',
                  subtitle: '그룹 초대장이 도착하면 알림을 받습니다',
                  value: isInvitationChecked,
                  onChanged:
                      !isAllChecked
                          ? null
                          : (val) {
                            setState(() => isInvitationChecked = val);
                            _saveSetting('invitation_noti', val);
                          },
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFF3F4F6)),
                const SizedBox(height: 16),
                _buildSwitchRow(
                  title: '서비스 공지 알림',
                  subtitle: '서비스 업데이트 및 공지사항 알림을 받습니다',
                  value: isServiceChecked,
                  onChanged:
                      !isAllChecked
                          ? null
                          : (val) {
                            setState(() => isServiceChecked = val);
                            _saveSetting('service_noti', val);
                          },
                ),
              ],
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  void _saveAllSubSettings(bool value) {
    _saveSetting('group_routine_noti', value);
    _saveSetting('group_todo_noti', value);
    _saveSetting('group_notice_noti', value);
    _saveSetting('calendar_noti', value);
    _saveSetting('invitation_noti', value);
    _saveSetting('service_noti', value);
  }

  Widget _buildInformationBox(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),

        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: Color(0xFFEFEFEF),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              "알림 해제는 휴대폰 설정 앱 > 알림 > 'OhMo'에서 설정할 수 있습니다",
              style: TextStyle(
                fontSize: 11,
                fontFamily: 'PretendardRegular',
                color: Color(0xFF3E3E3E),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBaseCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 3),
        ],
      ),

      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }

  Widget _buildSwitchRow({
    required String title,
    String? subtitle,
    required bool value,
    ValueChanged<bool>? onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'PretendardRegular',
                  color: Color(0xFF0A0A0A),
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'PretendardRegular',
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ],
          ),
        ),

        SizedBox(width: 16),
        CupertinoSwitch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.black,
        ),
      ],
    );
  }
}
