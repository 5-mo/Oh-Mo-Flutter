import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:ohmo/db/drift_database.dart';
import 'package:ohmo/db/local_category_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category_item.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:intl/intl.dart' as intl;
import 'package:ohmo/services/group_service.dart';

class MentionTextSpanBuilder extends SpecialTextSpanBuilder {
  @override
  SpecialText? createSpecialText(
    String flag, {
    TextStyle? textStyle,
    SpecialTextGestureTapCallback? onTap,
    int? index,
  }) {
    if (flag == '@') {
      return MentionText(textStyle, onTap);
    }
    return null;
  }
}

class MentionText extends SpecialText {
  MentionText(TextStyle? textStyle, SpecialTextGestureTapCallback? onTap)
    : super('@', ' ', textStyle, onTap: onTap);

  @override
  InlineSpan finishText() {
    final String content = getContent();
    String displayEx = content;

    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(3.0),
        ),
        child: Text(
          '@$displayEx',
          style: textStyle?.copyWith(color: Colors.grey[700]),
        ),
      ),
    );
  }
}

class GroupRoutineBottomSheet extends StatefulWidget {
  final int? groupId;
  final Future<void> Function()? onRoutineAdded;
  final Future<void> Function()? onDataChanged;
  final DateTime selectedDate;
  final int? routineIdToEdit;
  final Routine? routineToEdit;

  const GroupRoutineBottomSheet({
    Key? key,
    this.groupId,
    this.onRoutineAdded,
    this.onDataChanged,
    required this.selectedDate,
    this.routineIdToEdit,
    this.routineToEdit,
  }) : super(key: key);

  @override
  State<GroupRoutineBottomSheet> createState() =>
      _GroupRoutineBottomSheetState();
}

class _GroupRoutineBottomSheetState extends State<GroupRoutineBottomSheet> {
  late Map<String, String> _groupMembers = {};
  Map<String, int> _memberNameToId = {};
  List<String> _filterMembers = [];
  bool _showMentionSuggestions = false;
  final List<String> weekDays = ['월', '화', '수', '목', '금', '토', '일'];
  List<CategoryItem> routines = [];
  int? selectedCategoryId;
  List<String> selectedDays = [];
  double _mentionBoxOffsetx = 0.0;
  String? myNickname;

  final TextEditingController contentController = TextEditingController();
  final FocusNode _contentFocusNode = FocusNode();
  DateTime? selectedEndDate;
  TimeOfDay? selectedTime;
  bool isChecked = false;
  bool _isSaving = false;
  final LayerLink _textFieldLayerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  final GroupService _groupService = GroupService();

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadMembers().then((_) {
      if (widget.routineIdToEdit != null) {
        _loadRoutineDataForEdit();
      }
    });
    contentController.addListener(_onTextChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _showMentionTooltip();
      });
    });
  }

  @override
  void dispose() {
    _hideToolTip();
    contentController.removeListener(_onTextChanged);
    contentController.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  void _showMentionTooltip() async {
    final prefs = await SharedPreferences.getInstance();

    final bool hasShown = prefs.getBool('hasShownMentionTooltip') ?? false;

    if (!hasShown && mounted) {
      _overlayEntry = _createMentionOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
      await prefs.setBool('hasShownMentionTooltip', true);
    }
  }

  void _hideToolTip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createMentionOverlayEntry() {
    return OverlayEntry(
      builder:
          (context) => Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                CompositedTransformFollower(
                  link: _textFieldLayerLink,
                  showWhenUnlinked: false,
                  offset: const Offset(120, -20),
                  child: IntrinsicWidth(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 0),
                          child: CustomPaint(
                            size: const Size(8, 10),
                            painter: MentionTrianglePainter(
                              color: const Color(0xFF4E4E4E),
                              isLeft: true,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4E4E4E),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "멤버를 언급해서\n일정을 분담해보세요!",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontFamily: 'PretendardMedium'
                                ),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: _hideToolTip,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2A2A2A),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: const Text(
                                    "확인",
                                    style: TextStyle(
                                        color: Color(0xFFE6E6E6),
                                        fontSize: 12,
                                        fontFamily: 'PretendardMedium'
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  String _mapEngDayToNum(dynamic englishWeeks) {
    if (englishWeeks == null) return '';

    const Map<String, String> dayMap = {
      "MONDAY": "1",
      "TUESDAY": "2",
      "WEDNESDAY": "3",
      "THURSDAY": "4",
      "FRIDAY": "5",
      "SATURDAY": "6",
      "SUNDAY": "7",
    };

    if (englishWeeks is List) {
      return englishWeeks
          .map((e) => dayMap[e.toString().toUpperCase()] ?? '')
          .where((e) => e.isNotEmpty)
          .join(',');
    } else {
      return dayMap[englishWeeks.toString().toUpperCase()] ?? '';
    }
  }

  Future<void> _loadRoutineDataForEdit() async {
    final routine = widget.routineToEdit;
    if (routine == null) return;

    contentController.text = routine.content;

    final Map<String, String> numToDay = {
      '1': '월',
      '2': '화',
      '3': '수',
      '4': '목',
      '5': '금',
      '6': '토',
      '7': '일',
    };

    setState(() {
      if (routine.weekDays != null && routine.weekDays!.isNotEmpty) {
        final newDays = routine.weekDays!
            .split(',')
            .map((num) => numToDay[num.trim()] ?? '')
            .where((d) => d.isNotEmpty);

        selectedDays = {...selectedDays, ...newDays}.toList();
      }
    });

    try {
      if (routine.routineId == null) return;

      final detail = await _groupService.fetchAssigneeRoutine(
        routine.routineId!,
      );

      if (detail != null) {
        final routineInfo = detail['routine'];

        if (routineInfo != null) {
          final dynamic weeks =
              routineInfo['repeatWeek'] ??
              routineInfo['week'] ??
              routineInfo['weeks'];
          if (weeks != null) {
            setState(() {
              String mappedNums = _mapEngDayToNum(weeks);

              final serverDays = mappedNums
                  .split(',')
                  .map((n) => numToDay[n.trim()] ?? '')
                  .where((d) => d.isNotEmpty);

              selectedDays = {...selectedDays, ...serverDays}.toList();
            });
          }
        }
      }
    } catch (e) {
      print("상세 로드 중 오류: $e");
    }
  }

  void _onTextChanged() {
    final text = contentController.text;
    final cursorPos = contentController.selection.baseOffset;

    if (cursorPos < 0 || text.isEmpty) {
      setState(() => _showMentionSuggestions = false);
      return;
    }

    final int atIndex = text.substring(0, cursorPos).lastIndexOf('@');

    if (atIndex != -1) {
      final query = text.substring(atIndex + 1, cursorPos);

      if (query.contains(' ')) {
        setState(() => _showMentionSuggestions = false);
        return;
      }

      final filtered =
          _groupMembers.keys
              .where(
                (member) => member.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();

      if (filtered.isNotEmpty) {
        final prefixText = text.substring(0, atIndex);
        final painter = TextPainter(
          text: TextSpan(
            text: prefixText,
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
          textDirection: TextDirection.ltr,
        );
        painter.layout();

        setState(() {
          _mentionBoxOffsetx = painter.width + 16.0;
          _filterMembers = filtered;
          _showMentionSuggestions = true;
        });
      } else {
        setState(() => _showMentionSuggestions = false);
      }
    } else {
      setState(() => _showMentionSuggestions = false);
    }
  }

  Future<void> _loadMembers() async {
    if (widget.groupId == null) return;

    final myEmail = await _groupService.getMyEmail();

    final prefs = await SharedPreferences.getInstance();
    String? savedNickname = prefs.getString('group_nickname_${widget.groupId}');

    final allGroups = await _groupService.fetchGroups();
    String? serverGroupNickname;
    try {
      final currentGroup = allGroups.firstWhere(
        (g) => g['groupId'] == widget.groupId,
      );
      serverGroupNickname = currentGroup['nickname'];
    } catch (_) {}

    final memberData = await _groupService.fetchGroupMembers(widget.groupId!);

    if (memberData != null && mounted) {
      final List<dynamic> memberList =
          memberData['memberGroupInfos'] ?? memberData['memberDtoList'] ?? [];

      Map<String, String> updatedMembers = {
        '모두': 'android/assets/images/clear_ohmo.png',
      };
      Map<String, int> updatedIds = {};

      for (var member in memberList) {
        final memberInfo = member['memberInfo'] ?? {};
        final String email = memberInfo['email'] ?? '';

        String? groupNickname = member['nickname']?.toString();
        String? globalNickname = memberInfo['nickname']?.toString();

        String baseName = "이름 없음";

        if (email == myEmail) {
          baseName =
              savedNickname ??
              serverGroupNickname ??
              groupNickname ??
              globalNickname ??
              "나";
          myNickname = baseName;
        } else {
          baseName = groupNickname ?? globalNickname ?? "이름 없음";
        }

        updatedMembers[baseName] = memberInfo['profileImageUrl'] ?? "";
        updatedIds[baseName] = member['memberGroupId'] ?? 0;
      }

      setState(() {
        _groupMembers = updatedMembers;
        _memberNameToId = updatedIds;
        _filterMembers = _groupMembers.keys.toList();
      });
    }
  }

  void _onMemberSelected(String name) {
    final text = contentController.text;
    final cursorPos = contentController.selection.baseOffset;
    final int atIndex = text.substring(0, cursorPos).lastIndexOf('@');

    if (atIndex != -1) {
      String prefix = (atIndex > 0 && text[atIndex - 1] != ' ') ? " " : "";

      String insertName = name;
      final newText =
          text.substring(0, atIndex) +
          '$prefix@$insertName ' +
          text.substring(cursorPos);

      contentController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.fromPosition(
          TextPosition(offset: atIndex + prefix.length + insertName.length + 2),
        ),
      );
      _contentFocusNode.requestFocus();
    }

    setState(() {
      _showMentionSuggestions = false;
    });
  }

  void toggleDay(String day) {
    setState(() {
      if (selectedDays.contains(day)) {
        selectedDays.remove(day);
      } else {
        selectedDays.add(day);
      }
    });
  }

  List<String> getRoutineWeek() {
    Map<String, int> dayMap = {
      "월": 1,
      "화": 2,
      "수": 3,
      "목": 4,
      "금": 5,
      "토": 6,
      "일": 7,
    };
    final weekNumbers = selectedDays.map((d) => dayMap[d]!.toString()).toList();
    return weekNumbers;
  }

  List<String> convertToEnglishWeek(List<String> selectedDays) {
    const Map<String, String> dayMap = {
      "월": "MONDAY",
      "화": "TUESDAY",
      "수": "WEDNESDAY",
      "목": "THURSDAY",
      "금": "FRIDAY",
      "토": "SATURDAY",
      "일": "SUNDAY",
    };
    return selectedDays.map((d) => dayMap[d]!).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(30.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildRepeatDaysSection(),
              SizedBox(height: 20),
              _buildContentInputSection(),
              SizedBox(height: 20),
              _buildSaveButton(),
              SizedBox(height: bottomInset),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRepeatDaysSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "루틴 반복 요일",
          style: TextStyle(fontSize: 16, fontFamily: 'PretendardBold'),
        ),
        SizedBox(height: 16),
        Row(
          children:
              weekDays
                  .map(
                    (day) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: _buildDayButton(day),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }

  Widget _buildDayButton(String day) {
    final selected = selectedDays.contains(day);
    return GestureDetector(
      onTap: () => toggleDay(day),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? Colors.black : Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
          ],
        ),
        child: Center(
          child: Text(
            day,
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'PretendardBold',
              color: selected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "내용",
          style: TextStyle(fontSize: 16, fontFamily: 'PretendardBold'),
        ),
        SizedBox(height: 16),

        if (_showMentionSuggestions)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: _buildMentionSuggestions(),
          ),

        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: CompositedTransformTarget(
            link: _textFieldLayerLink,
            child: ExtendedTextField(
              controller: contentController,
              focusNode: _contentFocusNode,
              specialTextSpanBuilder: MentionTextSpanBuilder(),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintText: '내용을 입력하세요 (ex. @오모 발표자료 준비)',
              ),
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMentionSuggestions() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(6),
      elevation: 4.0,
      child: Container(
        constraints: const BoxConstraints(minWidth: 102, maxWidth: 120),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 1.0,
              spreadRadius: 0.5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                '멤버',
                style: TextStyle(fontSize: 9, color: Colors.grey[600]),
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                children:
                    _filterMembers.map((member) {
                      final bool isMe =
                          (member != '모두' &&
                              myNickname != null &&
                              member == myNickname);
                      final String showName = isMe ? '$member(나)' : member;

                      return InkWell(
                        onTap: () => _onMemberSelected(member),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 6.0,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.grey[200],
                                backgroundImage:
                                    (() {
                                          final path = _groupMembers[member];
                                          if (path == null || path.isEmpty)
                                            return null;

                                          if (path.startsWith('http')) {
                                            return NetworkImage(path);
                                          }
                                          if (path.startsWith(
                                            'android/assets',
                                          )) {
                                            return AssetImage(path);
                                          }
                                          return null;
                                        })()
                                        as ImageProvider?,
                                child:
                                    (() {
                                      final path = _groupMembers[member];
                                      if (path == null || path.isEmpty) {
                                        return Icon(
                                          Icons.person,
                                          size: 12,
                                          color: Colors.grey[400],
                                        );
                                      }
                                      return null;
                                    })(),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  showName,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    final bool isEditMode = widget.routineIdToEdit != null;

    return GestureDetector(
      onTap:
          _isSaving
              ? null
              : () async {
                final String content =
                    contentController.text.replaceAll('(나)', '').trim();

                if (content.isEmpty || selectedDays.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("요일과 내용을 모두 입력해주세요.")),
                  );
                  return;
                }
                setState(() => _isSaving = true);

                try {
                  final englishWeek = convertToEnglishWeek(selectedDays);
                  final DateTime threeMonthsLater = widget.selectedDate.add(
                    const Duration(days: 90),
                  );
                  final String formattedEndDate = intl.DateFormat(
                    'yyyy-MM-dd',
                  ).format(threeMonthsLater);

                  if (isEditMode) {
                    final bool success = await _groupService.updateGroupRoutine(
                      scheduleId: widget.routineIdToEdit!,
                      content: content,
                      routineWeek: englishWeek,
                      date: formattedEndDate,
                    );

                    if (success) {
                      final db = LocalDatabaseSingleton.instance;
                      await db.customUpdate(
                        'UPDATE routines SET content = ?, week_days = ? WHERE id = ?',
                        variables: [
                          drift.Variable<String>(content),
                          drift.Variable<String>(getRoutineWeek().join(',')),
                          drift.Variable<int>(widget.routineIdToEdit!),
                        ],
                        updates: {db.routines},
                      );

                      if (widget.onRoutineAdded != null)
                        await widget.onRoutineAdded!();
                      if (mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("루틴이 수정되었습니다!")),
                        );
                      }
                    } else {
                      print("서버 수정 실패 응답 받음");
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("서버 수정에 실패했습니다.")),
                        );
                      }
                    }
                  } else {
                    print("생성 모드 실행 - groupId: ${widget.groupId}");

                    final dynamic serverResponse = await _groupService
                        .createGroupRoutine(
                          groupId: widget.groupId ?? 0,
                          content: content,
                          routineWeek: englishWeek,
                          date: formattedEndDate,
                        );
                    print("서버 생성 응답: $serverResponse");

                    if (serverResponse != null) {
                      List<int> routineIds = [];
                      if (serverResponse is List) {
                        routineIds = List<int>.from(serverResponse);
                      } else if (serverResponse is int) {
                        routineIds = [serverResponse];
                      }

                      if (routineIds.isEmpty) {
                        print("에러: 루틴 ID가 반환되지 않음");
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("루틴 생성 중 오류가 발생했습니다. (ID 미수신)"),
                            ),
                          );
                        }
                        return;
                      }

                      List<int> selectedAssigneeIds = [];
                      if (content.contains('@모두')) {
                        _memberNameToId.forEach((name, id) {
                          if (name != '모두' && id != 0)
                            selectedAssigneeIds.add(id);
                        });
                      } else {
                        _memberNameToId.forEach((name, id) {
                          if (content.contains('@$name') && name != '모두') {
                            selectedAssigneeIds.add(id);
                          }
                        });
                      }

                      for (int rId in routineIds) {
                        if (selectedAssigneeIds.isNotEmpty) {
                          await _groupService.registerAssigneeRoutine(
                            routineId: rId,
                            memberGroupIdList: selectedAssigneeIds,
                          );
                        }
                      }

                      final db = LocalDatabaseSingleton.instance;
                      final weekString = getRoutineWeek().join(',');

                      final int localRoutineId = await db.insertRoutine(
                        RoutinesCompanion.insert(
                          groupId: drift.Value(widget.groupId),
                          content: content,
                          routineId: drift.Value(
                            routineIds.isNotEmpty ? routineIds.first : null,
                          ),
                          weekDays: drift.Value(weekString),
                          startDate: drift.Value(widget.selectedDate),
                          endDate: drift.Value(threeMonthsLater),
                          timeMinutes: const drift.Value(0),
                          categoryId: const drift.Value(1),
                          colorType: const drift.Value(0),
                          isDone: const drift.Value(false),
                        ),
                      );

                      if (widget.onRoutineAdded != null) {
                        await widget.onRoutineAdded!();
                      }
                      if (mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("3개월치 루틴이 등록되었습니다!")),
                        );
                      }
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("저장 중 오류가 발생했습니다.")),
                    );
                  }
                } finally {
                  if (mounted) {
                    setState(() => _isSaving = false);
                  }
                }
              },
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: _isSaving ? Colors.grey : Colors.black,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Center(
          child:
              _isSaving
                  ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                  : Text(
                    '저장하기',
                    style: const TextStyle(
                      fontSize: 20,
                      fontFamily: 'PretendardBold',
                      color: Colors.white,
                    ),
                  ),
        ),
      ),
    );
  }

  void _loadCategories() async {
    try {
      final localDb = LocalDatabaseSingleton.instance;
      final categoryRepo = LocalCategoryRepository(localDb);

      final loadedRoutines = await categoryRepo.fetchCategories(
        scheduleType: 'ROUTINE',
      );

      setState(() {
        routines = loadedRoutines;
        if (routines.isNotEmpty) selectedCategoryId = routines.first.id;
      });
    } catch (e) {
      print('카테고리 로드 실패: $e');
    }
  }
}

class MentionTrianglePainter extends CustomPainter {
  final Color color;
  final bool isLeft;

  MentionTrianglePainter({required this.color, this.isLeft = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();

    if (isLeft) {
      path.moveTo(size.width, 0);
      path.lineTo(0, size.height / 2);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(size.width / 2, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
