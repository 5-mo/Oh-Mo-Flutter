import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:ohmo/component/group_routine_bottom_sheet.dart';
import 'package:ohmo/const/colors.dart';
import 'package:ohmo/db/drift_database.dart';
import '../../component/color_palette_bottom_sheet.dart';
import '../../component/delete_bottom_sheet.dart';
import '../../component/group_routine_card.dart';
import '../../component/group_settings_bottom_sheet.dart';
import '../../component/group_todo_bottom_sheet.dart';
import '../../component/group_todo_card.dart';
import '../../component/main_calendar.dart';
import '../../component/routine_banner.dart';
import '../../component/todo_banner.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarEvent {
  final int id;
  final String content;
  final int currentCompletion;
  final int requiredCompletion;

  CalendarEvent({
    required this.id,
    required this.content,
    required this.currentCompletion,
    required this.requiredCompletion,
  });

  bool isFullyCompleted() {
    return requiredCompletion > 0 && currentCompletion >= requiredCompletion;
  }

  @override
  String toString() => content;
}

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
  Set<int> _completedTodoIds = {};

  final ValueNotifier<List<Routine>> _routinesNotifier = ValueNotifier([]);
  final ValueNotifier<List<Todo>> _todosNotifier = ValueNotifier([]);
  ColorType _currentColor = ColorType.pinkLight;
  int _memberCount = 0;
  Map<int, int> _routineCompletionCounts = {};
  Map<int, int> _todoCompletionCounts = {};
  String _groupName = '...';

  Map<DateTime, List<CalendarEvent>> _eventsCache = {};
  bool _needsRefresh = false;

  @override
  void initState() {
    super.initState();
    _db = LocalDatabaseSingleton.instance;
    _fetchGroupData(selectedDate);

    _loadSchedulesForMonth(selectedDate);
  }

  Future<void> _refreshAllData(DateTime date) async {
    await _loadSchedulesForMonth(date);
    await _fetchGroupData(date);
  }

  Future<void> _loadSchedulesForMonth(DateTime month) async {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);

    final allTodosInMonth = await _db.getTodosBetween(firstDay, lastDay);
    final allNoticesForGroup = await _db.getNoticesForGroup(widget.groupId);
    const int memberCount = 4;

    _eventsCache.clear();
    final mentionRegex = RegExp(r'@[\w\(\)가-힣]+');

    for (
      var day = firstDay;
      day.isBefore(lastDay.add(const Duration(days: 1)));
      day = day.add(const Duration(days: 1))
    ) {
      final dateOnly = DateTime(day.year, day.month, day.day);

      final todosForDay = allTodosInMonth.where(
        (todo) =>
            todo.groupId == widget.groupId && isSameDay(todo.date, dateOnly),
      );
      bool isTodoCompleted = false;

      if (todosForDay.isNotEmpty) {
        final todo = todosForDay.first;
        final mentions =
            mentionRegex
                .allMatches(todo.content)
                .map((m) => m.group(0)!)
                .toList();
        int requiredCount =
            (mentions.isEmpty || mentions.contains('@모두'))
                ? memberCount
                : mentions.length;
        final currentCount =
            (await _db.getTodoCompletionCount(todo.id, dateOnly)) ?? 0;

        if (requiredCount > 0 && currentCount >= requiredCount) {
          isTodoCompleted = true;
        }
      }

      if (isTodoCompleted) {
        _eventsCache[dateOnly] = [
          CalendarEvent(
            id: todosForDay.first.id,
            content: '',
            currentCompletion: 1,
            requiredCompletion: 1,
          ),
        ];
      } else {
        final noticesForDay = allNoticesForGroup.where(
          (notice) => isSameDay(notice.noticeDate, dateOnly),
        );
        if (noticesForDay.isNotEmpty) {
          final notice = noticesForDay.first;
          _eventsCache[dateOnly] = [
            CalendarEvent(
              id: notice.id,
              content: notice.content,
              currentCompletion: 0,
              requiredCompletion: 1,
            ),
          ];
        }
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _fetchGroupData(DateTime date) async {
    final group = await _db.getGroupById(widget.groupId);
    if (group == null) {
      if (mounted) {
        Navigator.pop(context, true);
      }
      return;
    }
    final routineIds = await _db.getCompletedRoutineIds(date);
    final allRoutines = await _db.getRoutinesByGroupId(widget.groupId);
    final routines =
        allRoutines
            .where((routine) => _isRoutineVisible(routine, date))
            .toList();

    final todoIds = await _db.getCompletedTodoIds(date);
    final todos = await _db.getTodosByGroupIdAndDate(widget.groupId, date);

    const int memberCount = 4;
    //final memberCount = await _db.getMemberCountInGroup(widget.groupId);
    final Map<int, int> routineCounts = {};
    final Map<int, int> todoCounts = {};

    for (var routine in routines) {
      routineCounts[routine.id] =
          (await _db.getCompletionCount(routine.id, date))!;
    }

    for (var todo in todos) {
      todoCounts[todo.id] = (await _db.getTodoCompletionCount(todo.id, date))!;
    }
    if (mounted) {
      setState(() {
        if (group != null) {
          _currentColor = ColorType.values[group.colorType];
          _groupName = group.name;
        }
        _completedRoutineIds = routineIds.toSet();
        _completedTodoIds = todoIds.toSet();
        _memberCount = memberCount ?? 0;
        _routineCompletionCounts = routineCounts;
        _todoCompletionCounts = todoCounts;
      });
      _routinesNotifier.value = routines;
      _todosNotifier.value = todos;
    }
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      selectedDate = selectedDay;
    });
    _fetchGroupData(selectedDay);
  }

  bool _isRoutineVisible(Routine routine, DateTime date) {
    if (routine.startDate == null ||
        routine.endDate == null ||
        routine.weekDays == null) {
      return false;
    }
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
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _needsRefresh);
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          surfaceTintColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: () {
              Navigator.pop(context, _needsRefresh);
            },
          ),
          backgroundColor: ColorManager.getColor(_currentColor),
        ),
        backgroundColor: ColorManager.getColor(_currentColor),

        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Row(children: [_buildGroupName(), Spacer(), _buildSetting()]),
                SizedBox(height: 10.0),
                NoticeSection(
                  groupId: widget.groupId,
                  onNoticeChanged: () => _refreshAllData(selectedDate),
                ),
                SizedBox(height: 10.0),
                _buildGroupCalendar(),
                SizedBox(height: 60.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupName() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22.0),
      child: Text(
        _groupName,
        style: TextStyle(fontFamily: 'PretendardRegular', fontSize: 24.0),
      ),
    );
  }

  Widget _buildSetting() {
    return IconButton(
      onPressed: () async {
        final result = await showModalBottomSheet<dynamic>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(59),
              topRight: Radius.circular(59),
            ),
          ),
          builder: (_) => GroupSettingsBottomSheet(groupId: widget.groupId),
        );
        if (result == 'leave') {
          _needsRefresh = true;
          if (mounted) {
            Navigator.pop(context, _needsRefresh);
          }
        } else if (result == true) {
          _needsRefresh = true;
          await _fetchGroupData(selectedDate);
        }
      },
      padding: const EdgeInsets.symmetric(horizontal: 22.0),
      constraints: const BoxConstraints(),
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
            eventLoader: (day) {
              final dateOnly = DateTime(day.year, day.month, day.day);
              return _eventsCache[dateOnly] ?? [];
            },
            onPageChanged: (focusedDay) {
              _loadSchedulesForMonth(focusedDay);
            },
            headerPadding: const EdgeInsets.symmetric(
              horizontal: 15.0,
              vertical: 15.0,
            ),
            headerTextStyle: TextStyle(
              fontFamily: 'RubikSprayPaint',
              fontSize: 24.0,
            ),
            formatButtonSize: 17.0,
            monthButtonOffset: Offset(30, -5),
            weekButtonOffset: Offset(5, -5),
            dayFontSize: 14.0,
            calendarPadding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 20.0,
            ),
            headerDateFormat: '  MMM',
            onAlarmIconPressed: null,
            hasUnread: false,
            markerColor: _currentColor,
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
              addButtonOffset: Offset(3, 0),
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

                      final bool isIndicatorVisible = mentions.isNotEmpty;
                      final bool isCheckboxVisible =
                          mentions.contains('@모두') ||
                          mentions.any((m) => m.contains('(나)'));

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
                            _routineCompletionCounts[routine.id] ?? 0,
                        isIndicatorVisible: isIndicatorVisible,
                        isCheckboxVisible: isCheckboxVisible,
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
                      onTodoAdded: () => _refreshAllData(selectedDate),
                      selectedDate: selectedDate,
                    );
                  },
                );
              },
              addButtonOffset: Offset(4, 0),
            ),
          ),
          ValueListenableBuilder<List<Todo>>(
            valueListenable: _todosNotifier,
            builder: (context, todos, _) {
              if (todos.isEmpty) return const SizedBox(height: 20);
              return Column(
                children:
                    todos.map((todo) {
                      final mentionRegex = RegExp(r'@[\w\(\)가-힣]+');
                      final mentions =
                          mentionRegex
                              .allMatches(todo.content)
                              .map((m) => m.group(0)!)
                              .toList();

                      final bool isIndicatorVisible = mentions.isNotEmpty;
                      final bool isCheckboxVisible =
                          mentions.contains('@모두') ||
                          mentions.any((m) => m.contains('(나)'));

                      int totalCountForThisTodo;
                      if (mentions.isEmpty || mentions.contains('@모두')) {
                        totalCountForThisTodo = _memberCount;
                      } else {
                        totalCountForThisTodo = mentions.length;
                      }

                      final isDoneForDay = _completedTodoIds.contains(todo.id);

                      return GroupTodoCard(
                        todo: todo,
                        isDoneForDay: isDoneForDay,
                        selectedDate: selectedDate,
                        totalMemberCount: totalCountForThisTodo,
                        completedMemberCount:
                            _todoCompletionCounts[todo.id] ?? 0,
                        isIndicatorVisible: isIndicatorVisible,
                        isCheckboxVisible: isCheckboxVisible,
                        onDataChanged: () => _refreshAllData(selectedDate),
                      );
                    }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class NoticeSection extends StatefulWidget {
  final int groupId;
  final VoidCallback onNoticeChanged;

  const NoticeSection({
    super.key,
    required this.groupId,
    required this.onNoticeChanged,
  });

  @override
  State<NoticeSection> createState() => _NoticeSectionState();
}

class _NoticeSectionState extends State<NoticeSection> {
  final LocalDatabase _db = LocalDatabaseSingleton.instance;
  bool _isAddingNewNotice = false;
  final _newNoticeController = TextEditingController();
  List<Notice> _notices = [];
  DateTime? _selectedDate;

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

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final futureNotices =
        noticesFromDb.where((notice) {
          final noticeDateOnly = DateTime(
            notice.noticeDate.year,
            notice.noticeDate.month,
            notice.noticeDate.day,
          );
          return !noticeDateOnly.isBefore(today);
        }).toList();

    futureNotices.sort((a, b) {
      final dateComparison = a.noticeDate.compareTo(b.noticeDate);

      if (dateComparison != 0) {
        return dateComparison;
      } else {
        return b.createdAt.compareTo(a.createdAt);
      }
    });

    if (mounted) {
      setState(() {
        _notices = noticesFromDb;
      });
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(3000),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.black,
            colorScheme: const ColorScheme.light(primary: Colors.black),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.black),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _addNotice() async {
    final content = _newNoticeController.text.trim();
    if (content.isNotEmpty && _selectedDate != null) {
      final group = await _db.getGroupById(widget.groupId);
      final groupName = group?.name ?? "ohmo";

      final noticeDateStr = DateFormat('MM/dd').format(_selectedDate!);

      String line1 = "'$groupName' 그룹에 새로운 공지가 등록되었습니다.";
      String line2 = "[공지] $content(일시 : $noticeDateStr)";

      final String multiLineContent = "$line1\n$line2";

      final newNotice = NoticesCompanion.insert(
        content: content,
        createdAt: DateTime.now(),
        groupId: drift.Value(widget.groupId),
        noticeDate: _selectedDate!,
      );
      final int newNoticeId = await _db.insertNotice(newNotice);
      String shortContent =
          content.length > 20 ? "${content.substring(0, 20)}..." : content;
      await _db.insertNotification(
        NotificationsCompanion(
          type: drift.Value('group'),
          content: drift.Value(multiLineContent),
          timestamp: drift.Value(DateTime.now()),
          relatedId: drift.Value(newNoticeId),
          isRead: drift.Value(true),
        ),
      );

      _newNoticeController.clear();
      setState(() {
        _isAddingNewNotice = false;
        _selectedDate = null;
      });
      _fetchNotices();
      widget.onNoticeChanged();
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
                      if (_isAddingNewNotice) {
                        _selectedDate = DateTime.now();
                      } else {
                        _selectedDate = null;
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(7.0),
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
    final formattedDate = DateFormat('M/d').format(notice.noticeDate);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              '$formattedDate',
              style: TextStyle(
                fontFamily: 'PretendardRegular',
                color: Colors.white,
                fontSize: 15,
                height: 1,
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              notice.content,
              style: TextStyle(
                fontFamily: 'PretendardSemibold',
                color: Colors.white,
                fontSize: 16,
                height: 1.3,
              ),
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
                      widget.onNoticeChanged();
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
    if (_selectedDate == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: () => _pickDate(context),
            borderRadius: BorderRadius.circular(8.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                DateFormat('M/d').format(_selectedDate!),
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 8),

          Expanded(
            child: TextField(
              controller: _newNoticeController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: '새로운 공지를 입력하세요',
                hintStyle: const TextStyle(color: Colors.grey),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.white, width: 2),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: _selectedDate != null ? _addNotice : null,
          ),
        ],
      ),
    );
  }
}
