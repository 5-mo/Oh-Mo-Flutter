import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ohmo/component/delete_bottom_sheet.dart';
import 'package:ohmo/db/drift_database.dart';

import '../const/colors.dart';

class GroupRoutineCard extends StatefulWidget {
  final Routine routine;
  final bool isDoneForDay;
  final DateTime selectedDate;
  final Future<void> Function()? onDataChanged;
  final int totalMemberCount;
  final int completedMemberCount;
  final bool isIndicatorVisible;
  final bool isCheckboxVisible;

  const GroupRoutineCard({
    Key? key,
    required this.routine,
    required this.isDoneForDay,
    required this.selectedDate,
    this.onDataChanged,
    required this.totalMemberCount,
    required this.completedMemberCount,
    required this.isIndicatorVisible,
    required this.isCheckboxVisible,
  }) : super(key: key);

  @override
  _GroupRoutineCardState createState() => _GroupRoutineCardState();
}

class _GroupRoutineCardState extends State<GroupRoutineCard> {
  Widget _buildCompletionIndicator() {
    if (widget.totalMemberCount <= 0) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        widget.totalMemberCount,
        (index) => Container(
          width: 14,
          height: 4,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color:
                index < widget.completedMemberCount
                    ? Colors.black
                    : Colors.grey[300],
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String originalContent = widget.routine.content;
    final mentionRegex = RegExp(r'@[\w\(\)가-힣]+');
    final allMentions =
        mentionRegex
            .allMatches(originalContent)
            .map((m) => m.group(0)!)
            .toList();
    final mainContent = originalContent.replaceAll(mentionRegex, '').trim();
    final mentionsText = allMentions.join(' ');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3.0, left: 6.0),
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 12.0),

          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14.0,
                  fontFamily: 'PretendardRegular',
                  decoration:
                      widget.isDoneForDay
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                  color: widget.isDoneForDay ? Middle_GREY_COLOR : Colors.black,
                  decorationColor: Middle_GREY_COLOR,
                ),
                children: [
                  TextSpan(text: mainContent),
                  TextSpan(
                    text: ' $mentionsText',
                    style: TextStyle(
                      color:
                          widget.isDoneForDay
                              ? Middle_GREY_COLOR
                              : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.isIndicatorVisible)
                Transform.translate(
                  offset: const Offset(13, -15.0),
                  child: _buildCompletionIndicator(),
                ),
              if (widget.isIndicatorVisible) const SizedBox(width: 8),

              Transform.translate(
                offset: const Offset(0, -15.0),
                child: Transform.scale(
                  scale: 0.8,
                  child:
                      widget.isCheckboxVisible
                          ? Checkbox(
                            value: widget.isDoneForDay,
                            onChanged: (value) async {
                              final db = LocalDatabaseSingleton.instance;
                              await db.toggleRoutineCompletion(
                                widget.routine.id,
                                widget.selectedDate,
                              );
                              widget.onDataChanged?.call();
                            },
                            activeColor: Colors.black,
                            checkColor: Colors.white,
                            fillColor: MaterialStateProperty.all(Colors.black),
                          )
                          : const SizedBox(
                            width: kMinInteractiveDimension,
                            height: kMinInteractiveDimension,
                          ),
                ),
              ),
              Transform.translate(
                offset: const Offset(-5, -15.0),
                child: GestureDetector(
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
                            await db.deactivateRoutine(
                              widget.routine.id,
                              widget.selectedDate,
                            );

                            widget.onDataChanged?.call();
                          },
                        );
                      },
                    );
                  },
                  child: Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.all(2.0),
                    child: SvgPicture.asset(
                      'android/assets/images/routine_alarm.svg',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
