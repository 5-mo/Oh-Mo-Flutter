import 'package:drift/drift.dart' as drift;
import 'dart:ui' as ui;
import 'package:flutter/material.dart' ;
import 'package:ohmo/db/drift_database.dart';
import 'package:ohmo/db/local_category_repository.dart';
import '../models/category_item.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:intl/intl.dart';

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

class GroupTodoBottomSheet extends StatefulWidget {
  final int? groupId;
  final Future<void> Function()? onTodoAdded;
  final Future<void> Function()? onDataChanged;
  final DateTime selectedDate;

  const GroupTodoBottomSheet({
    Key? key,
    this.groupId,
    this.onTodoAdded,
    this.onDataChanged,
    required this.selectedDate,
  }) : super(key: key);

  @override
  State<GroupTodoBottomSheet> createState() => _GroupTodoBottomSheetState();
}

class _GroupTodoBottomSheetState extends State<GroupTodoBottomSheet> {
  final Map<String, String> _groupMembers = {
    '모두': 'android/assets/images/clear_ohmo.png',
    '재원(나)': 'android/assets/images/clear_ohmo.png',
    '유진': 'android/assets/images/clear_ohmo.png',
    '은지': 'android/assets/images/clear_ohmo.png',
    '효진': 'android/assets/images/clear_ohmo.png',
  };
  List<String> _filterMembers = [];
  bool _showMentionSuggestions = false;
  List<CategoryItem> todos = [];
  int? selectedCategoryId;
  double _mentionBoxOffsetx = 0.0;

  final TextEditingController contentController = TextEditingController();
  final FocusNode _contentFocusNode = FocusNode();
  DateTime? selectedEndDate;
  TimeOfDay? selectedTime;
  bool isChecked = false;

  @override
  void initState() {
    super.initState();
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
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
          textDirection: ui.TextDirection.ltr,
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

  Widget _buildContentInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "내용",
          style: TextStyle(fontSize: 16, fontFamily: 'PretendardBold'),
        ),
        const SizedBox(height: 16),

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
                            imagePath != null ? AssetImage(imagePath) : null,
                        child:
                            imagePath == null
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
        final String originalContent = contentController.text.trim();

        if (originalContent.isEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("내용을 입력해주세요.")));
          return;
        }

        final mentionRegex = RegExp(r'@');
        String finalContent = originalContent;

        if (!mentionRegex.hasMatch(originalContent)) {
          finalContent = '$originalContent @모두';
        }

        try {
          final db = LocalDatabaseSingleton.instance;

          final int newTodoId = await db.insertTodo(
            TodosCompanion.insert(
              groupId: drift.Value(widget.groupId),
              content: finalContent,
              date: widget.selectedDate,
            ),
          );
          if (finalContent.contains('(나)') || finalContent.contains('@모두')) {
            final group = await db.getGroupById(widget.groupId ?? 0);
            final groupName = group?.name ?? "ohmo";
            final todoDateStr = DateFormat('MM/dd').format(widget.selectedDate);

            String line1 = "'$groupName' 그룹에 새로운 할 일이 등록되었습니다.";
            String line2 = "[To-do] $finalContent ( ~$todoDateStr까지)";
            final String multiLineContent = "$line1\n$line2";

            await db.insertNotification(
              NotificationsCompanion(
                type: drift.Value('group'),
                content: drift.Value(multiLineContent),
                timestamp: drift.Value(DateTime.now()),
                relatedId: drift.Value(newTodoId),
                isRead: drift.Value(true),
              ),
            );
          }
          widget.onTodoAdded?.call();

          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("투두가 등록되었습니다!")));
          }
        } catch (e) {
          print('투두 저장 실패: $e');
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('투두 저장에 실패했습니다.')));
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
}
