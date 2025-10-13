import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:ohmo/component/group_routine_bottom_sheet.dart';
import 'package:ohmo/const/colors.dart';
import 'package:ohmo/db/drift_database.dart';
import '../component/delete_bottom_sheet.dart';
import '../component/group_routine_card.dart';
import '../component/group_todo_bottom_sheet.dart';
import '../component/main_calendar.dart';
import '../component/routine_banner.dart';
import '../component/todo_banner.dart';

class GroupMainScreen extends StatefulWidget {
  final int groupId;

  const GroupMainScreen({super.key, required this.groupId});

  @override
  State<GroupMainScreen> createState() => _GroupMainScreenState();
}

class _GroupMainScreenState extends State<GroupMainScreen> {
  DateTime selectedDate = DateTime.now();
  late final LocalDatabase _db;
  Set<int> _completedRoutineIds = {};

  final ValueNotifier<List<Routine>> _routinesNotifier = ValueNotifier([]);

  int _memberCount = 0;
  Map<int, int> _completionCounts = {};

  @override
  void initState() {
    super.initState();
    _db = LocalDatabaseSingleton.instance;
    _fetchGroupData(selectedDate);
  }

  Future<void> _fetchGroupData(DateTime date) async {
    final ids = await _db.getCompletedRoutineIds(date);
    final routines = await _db.getRoutinesByGroupId(widget.groupId);
    const int memberCount = 4;
    //final memberCount = await _db.getMemberCountInGroup(widget.groupId);
    final Map<int, int> completionCounts = {};
    for (var routine in routines) {
      if (_isRoutineVisible(routine, date)) {
        completionCounts[routine.id] =
            (await _db.getCompletionCount(routine.id, date))!;
      }
    }
    if (mounted) {
      setState(() {
        _completedRoutineIds = ids.toSet();
        _memberCount = memberCount ?? 0;
        _completionCounts = completionCounts;
      });
      _routinesNotifier.value = routines;
    }
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      selectedDate = selectedDay;
    });
    _fetchGroupData(selectedDay);
  }

  bool _isRoutineVisible(Routine routine, DateTime date) {
    final checkDate = DateTime(date.year, date.month, date.day);
    final startDate = DateTime(
      routine.startDate!.year,
      routine.startDate!.month,
      routine.startDate!.day,
    );
    final endDate = DateTime(
      routine.endDate!.year,
      routine.endDate!.month,
      routine.endDate!.day,
    );
    if (checkDate.isBefore(startDate) || checkDate.isAfter(endDate)) {
      return false;
    }
    final weekDays = routine.weekDays?.split(',').map(int.parse).toList() ?? [];
    if (!weekDays.contains(checkDate.weekday)) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: ColorManager.getColor(ColorType.pinkLight),
      ),
      backgroundColor: ColorManager.getColor(ColorType.pinkLight),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Row(children: [_buildGroupName(), Spacer(), _buildSetting()]),
              SizedBox(height: 10.0),
              NoticeSection(groupId: widget.groupId),
              SizedBox(height: 10.0),
              _buildGroupCalendar(),
              SizedBox(height: 60.0)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupName() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22.0),
      child: Text(
        '사이드 프로젝트',
        style: TextStyle(fontFamily: 'PretendardRegular', fontSize: 24.0),
      ),
    );
  }

  Widget _buildSetting() {
    return IconButton(
      onPressed: () {},
      padding: const EdgeInsets.symmetric(horizontal: 22.0),
      constraints: BoxConstraints(),
      icon: SvgPicture.asset('android/assets/images/setting.svg'),
    );
  }

  Widget _buildGroupCalendar() {
    return Container(
      width: 318,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 8),
          MainCalendar(
            selectedDate: selectedDate,
            onDaySelected: onDaySelected,
            eventLoader: (_) => [],
            headerPadding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 8.0,
            ),
            headerTextStyle: TextStyle(
              fontFamily: 'RubikSprayPaint',
              fontSize: 24.0,
            ),
            formatButtonSize: 17.0,
            formatButtonGapOffset: Offset(25, 0),
            dayFontSize: 14.0,
            calendarPadding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 20.0,
            ),
            headerDateFormat: '  MMM',
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: RoutineBanner(
              onAddPressed: () {
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
                  builder: (_) {
                    return GroupRoutineBottomSheet(
                      groupId: widget.groupId,
                      onRoutineAdded: () => _fetchGroupData(selectedDate),
                      selectedDate: selectedDate,
                    );
                  },
                );
              },
            ),
          ),
          ValueListenableBuilder<List<Routine>>(
            valueListenable: _routinesNotifier,
            builder: (context, routines, _) {
              final visibleRoutines =
                  routines
                      .where((r) => _isRoutineVisible(r, selectedDate))
                      .toList();
              if (visibleRoutines.isEmpty) return const SizedBox(height: 20);
              return Column(
                children:
                    visibleRoutines.map((routine) {
                      final mentionRegex = RegExp(r'@[\w\(\)가-힣]+');
                      final mentions =
                          mentionRegex
                              .allMatches(routine.content)
                              .map((m) => m.group(0)!)
                              .toList();

                      final bool isIndicatorVisible=mentions.isNotEmpty;
                      final bool isCheckboxVisible =
                          mentions.contains('@모두') || mentions.any((m) => m.contains('(나)'));

                      int totalCountForThisRoutine;
                      if (mentions.isEmpty || mentions.contains('@모두')) {
                        totalCountForThisRoutine = _memberCount;
                      } else {
                        totalCountForThisRoutine = mentions.length;
                      }

                      final isDoneForDay = _completedRoutineIds.contains(
                        routine.id,
                      );
                      return GroupRoutineCard(
                        routine: routine,
                        isDoneForDay: isDoneForDay,
                        selectedDate: selectedDate,
                        totalMemberCount: totalCountForThisRoutine,
                        completedMemberCount:
                            _completionCounts[routine.id] ?? 0,
                        isIndicatorVisible:isIndicatorVisible,
                        isCheckboxVisible:isCheckboxVisible,
                        onDataChanged: () => _fetchGroupData(selectedDate),
                      );
                    }).toList(),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: TodoBanner(
              onAddPressed: () {
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
                  builder: (_) {
                    return GroupTodoBottomSheet(
                      groupId: widget.groupId,
                      onTodoAdded: () => _fetchGroupData(selectedDate),
                      selectedDate: selectedDate,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class NoticeSection extends StatefulWidget {
  final int groupId;

  const NoticeSection({super.key, required this.groupId});

  @override
  State<NoticeSection> createState() => _NoticeSectionState();
}

class _NoticeSectionState extends State<NoticeSection> {
  final LocalDatabase _db = LocalDatabaseSingleton.instance;
  bool _isAddingNewNotice = false;
  final _newNoticeController = TextEditingController();
  List<Notice> _notices = [];

  @override
  void initState() {
    super.initState();
    _fetchNotices();
  }

  @override
  void dispose() {
    _newNoticeController.dispose();
    super.dispose();
  }

  Future<void> _fetchNotices() async {
    final noticesFromDb = await _db.getNoticesForGroup(widget.groupId);
    if (mounted) {
      setState(() {
        _notices = noticesFromDb;
      });
    }
  }

  Future<void> _addNotice() async {
    final content = _newNoticeController.text.trim();
    if (content.isNotEmpty) {
      final newNotice = NoticesCompanion.insert(
        content: content,
        createdAt: DateTime.now(),
        groupId: drift.Value(widget.groupId),
      );
      await _db.insertNotice(newNotice);
      _newNoticeController.clear();
      setState(() {
        _isAddingNewNotice = false;
      });
      _fetchNotices();
    }
  }

  @override
  Widget build(BuildContext context) {
    const titleTextStyle = TextStyle(
      fontFamily: 'RubikSprayPaint',
      fontSize: 16.0,
      color: Colors.white,
    );

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        width: 318,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text('Notice', style: titleTextStyle),
                Spacer(),
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    setState(() {
                      _isAddingNewNotice = !_isAddingNewNotice;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: SvgPicture.asset(
                      'android/assets/images/plus.svg',
                      colorFilter: ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 8),

            if (_notices.length > 2)
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 53.0),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _notices.length,
                  itemBuilder: (context, index) {
                    final notice = _notices[index];
                    return _buildNoticeItem(notice);
                  },
                ),
              )
            else
              ..._notices.map((notice) => _buildNoticeItem(notice)).toList(),
            if (_notices.isEmpty && !_isAddingNewNotice)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  '등록된 공지사항이 없습니다.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),

            if (_isAddingNewNotice) _buildInputField(),
          ],
        ),
      ),
    );
  }

  Widget _buildNoticeItem(Notice notice) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text(
            '•',
            style: TextStyle(color: Colors.white, fontSize: 16, height: 1),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              notice.content,
              style: TextStyle(color: Colors.white, fontSize: 16, height: 1.3),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(59),
                    topLeft: Radius.circular(59),
                  ),
                ),
                builder: (BuildContext bContext) {
                  return DeleteBottomSheet(
                    onDelete: () async {
                      final db = LocalDatabaseSingleton.instance;
                      await db.deleteNotice(notice.id);
                      _fetchNotices();
                    },
                  );
                },
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SvgPicture.asset(
                'android/assets/images/routine_alarm.svg',
                colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _newNoticeController,
              autofocus: true,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: '새로운 공지를 입력하세요',
                hintStyle: TextStyle(color: Colors.grey),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white, width: 2),
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.check, color: Colors.white),
            onPressed: _addNotice,
          ),
        ],
      ),
    );
  }
}
