import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:ohmo/db/drift_database.dart';
import 'package:ohmo/db/local_category_repository.dart';
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
    final String text = '$startFlag${getContent()}';

    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(3.0),
        ),
        child: Text(text, style: textStyle?.copyWith(color: Colors.grey[700])),
      ),
    );
  }
}

class GroupRoutineBottomSheet extends StatefulWidget {
  final int? groupId;
  final Future<void> Function()? onRoutineAdded;
  final Future<void> Function()? onDataChanged;
  final DateTime selectedDate;

  const GroupRoutineBottomSheet({
    Key? key,
    this.groupId,
    this.onRoutineAdded,
    this.onDataChanged,
    required this.selectedDate,
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

  final TextEditingController contentController = TextEditingController();
  final FocusNode _contentFocusNode = FocusNode();
  DateTime? selectedEndDate;
  TimeOfDay? selectedTime;
  bool isChecked = false;

  final GroupService _groupService = GroupService();

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadMembers();
    contentController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    contentController.removeListener(_onTextChanged);
    contentController.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = contentController.text;
    final cursorPos = contentController.selection.baseOffset;

    final int atIndex = text.substring(0, cursorPos).lastIndexOf('@');
    if (atIndex != -1) {
      final query = text.substring(atIndex + 1, cursorPos);
      if (!query.contains(' ')) {
        final prefixText = text.substring(0, atIndex);

        final painter = TextPainter(
          text: TextSpan(
            text: prefixText,
            style: TextStyle(fontSize: 14, color: Colors.black),
          ),
          textDirection: TextDirection.ltr,
        );
        painter.layout();

        final calculatedOffset = painter.width + 16.0;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() {
            _mentionBoxOffsetx = calculatedOffset;
            _filterMembers =
                _groupMembers.keys
                    .where(
                      (member) =>
                          member.toLowerCase().contains(query.toLowerCase()),
                    )
                    .toList();
            _showMentionSuggestions = _filterMembers.isNotEmpty;
          });
          if (_filterMembers.isNotEmpty) _contentFocusNode.requestFocus();
        });
        return;
      }
    }
    Future(() {
      setState(() {
        _showMentionSuggestions = false;
      });
    });
  }

  Future<void> _loadMembers() async {
    if (widget.groupId == null) return;

    final myEmail = await _groupService.getMyEmail();

    final memberData = await _groupService.fetchGroupMembers(widget.groupId!);

    if (memberData != null && mounted) {
      final List<dynamic> memberList = memberData['memberDtoList'] ?? [];

      Map<String, String> updatedMembers = {
        '모두': 'android/assets/images/clear_ohmo.png',
      };

      Map<String, int> updatedIds = {};

      for (var member in memberList) {
        String baseName =
            member['groupNickname'] ?? member['nickname'] ?? '이름 없음';
        String email = member['email'] ?? '';
        int assigneeId = member['assigneeId'] ?? 0;
        String displayName = (email == myEmail) ? '$baseName(나)' : baseName;

        updatedMembers[displayName] = 'android/assets/images/clear_ohmo.png';
        updatedIds[displayName] = assigneeId;
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
      String prefix = "";
      if (atIndex > 0 && text[atIndex - 1] != ' ') {
        prefix = " ";
      }
      final newText =
          text.substring(0, atIndex) +
          '$prefix@$name ' +
          text.substring(cursorPos);

      contentController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.fromPosition(
          TextPosition(offset: atIndex + prefix.length + name.length + 2),
        ),
      );
      _contentFocusNode.requestFocus();
    }
    Future(() {
      setState(() {
        _showMentionSuggestions = false;
      });
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
      ],
    );
  }

  Widget _buildMentionSuggestions() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(6),
      elevation: 4.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 0),
        width: 102,
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
            ..._filterMembers.map((member) {
              final imagePath = _groupMembers[member];

              return InkWell(
                onTapDown: (_) {
                  _onMemberSelected(member);
                },
                splashColor: Colors.grey[300],
                highlightColor: Colors.grey[200],
                child: Container(
                  color: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 2.0,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 9,
                        backgroundImage:
                            imagePath != null &&
                                    imagePath.startsWith('android/assets')
                                ? AssetImage(imagePath)
                                : null,
                        child:
                            imagePath == null ||
                                    !imagePath.startsWith('android/assets')
                                ? Icon(Icons.person, size: 11)
                                : null,
                      ),
                      SizedBox(width: 6),
                      Text(
                        member,
                        style: TextStyle(fontSize: 10, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: () async {
        final String content = contentController.text;

        if (content.isEmpty || selectedDays.isEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("요일과 내용을 모두 입력해주세요.")));
          return;
        }

        List<int> selectedAssigneeIds = [];
        if (content.contains('@모두')) {
          selectedAssigneeIds = _memberNameToId.values.toList();
        } else {
          _memberNameToId.forEach((name, id) {
            if (content.contains('@$name')) {
              selectedAssigneeIds.add(id);
            }
          });
        }

        try {
          final englishWeek = convertToEnglishWeek(selectedDays);
          final formattedDate = intl.DateFormat(
            'yyyy-MM-dd',
          ).format(widget.selectedDate);

          final int? serverRoutineId = await _groupService.createGroupRoutine(
            groupId: widget.groupId ?? 0,
            content: content,
            routineWeek: englishWeek,
            date: formattedDate,
          );

          if (serverRoutineId != null) {
            if (selectedAssigneeIds.isNotEmpty) {
              await _groupService.registerAssigneeRoutine(
                routineId: serverRoutineId,
                memberGroupIdList: selectedAssigneeIds,
              );
            }
            final db = LocalDatabaseSingleton.instance;
            final weekString = getRoutineWeek().join(',');

            final int localRoutineId = await db.insertRoutine(
              RoutinesCompanion.insert(
                groupId: drift.Value(widget.groupId),
                content: contentController.text,
                weekDays: drift.Value(weekString),
                startDate: drift.Value(widget.selectedDate),
                endDate: drift.Value(DateTime(9999, 12, 31)),
                timeMinutes: const drift.Value(0),
                categoryId: const drift.Value(1),
                colorType: const drift.Value(0),
                isDone: const drift.Value(false),
              ),
            );

            if (content.contains('(나)') || content.contains('@모두')) {
              final group = await db.getGroupById(widget.groupId ?? 0);
              final groupName = group?.name ?? "현재 그룹";
              final days = selectedDays.join(',');

              String line1 = "'$groupName' 그룹에 새로운 할 일이 등록되었습니다.";
              String line2 = "[Routine] $content (매주 $days)";
              final String multiLineContent = "$line1\n$line2";

              await db.insertNotification(
                NotificationsCompanion(
                  type: drift.Value('group'),
                  content: drift.Value(multiLineContent),
                  timestamp: drift.Value(DateTime.now()),
                  relatedId: drift.Value(localRoutineId),
                  isRead: drift.Value(true),
                ),
              );
            }

            if (widget.onRoutineAdded != null) {
              await widget.onRoutineAdded!();
            }

            if (mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("루틴이 등록되었습니다!")));
            }
          } else {
            throw Exception("서버 등록 실패");
          }
        } catch (e) {
          print('루틴 저장 실패: $e');
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('루틴 저장에 실패했습니다.')));
          }
        }
      },
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(9),
        ),
        child: const Center(
          child: Text(
            '저장하기',
            style: TextStyle(
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
