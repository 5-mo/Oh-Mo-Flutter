import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ohmo/component/delete_popup.dart';
import 'package:ohmo/component/routine_card.dart';
import 'package:ohmo/const/colors.dart';
import 'package:ohmo/shared_data.dart';
import 'package:ohmo/component/todo_card.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String _newEmoji = '🙂';
  TextEditingController _newQuestionController = TextEditingController();
  bool _isAddingNewQuestion = false;
  final GlobalKey<ExpansionTileCardState> _daylogTileKey = GlobalKey();

  bool _isRoutineDeleted = false;
  bool _isTodoDeleted = false;
  bool _isDaylogDeleted = false;
  bool _isDiaryDeleted = false;

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
        backgroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 30, left: 35, bottom: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryHeader(),
            SizedBox(height: 20.0),
            _buildRoutineAccordion(),
            _buildTodoAccordion(),
            _buildDaylogAccordion(),
            SizedBox(height: 10.0),
            _buildDiaryIndex(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryHeader() {
    return Text(
      '카테고리 관리',
      style: TextStyle(fontFamily: 'PretendardBold', fontSize: 18.0),
    );
  }

  Widget _buildRoutineAccordion() {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Slidable(
        key: ValueKey('routineCategory'),
        endActionPane: ActionPane(
          motion: ScrollMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              onPressed: (context) {
                showDialog(
                  context: context,
                  builder:
                      (context) => DeletePopup(
                        onDelete: () {
                          setState(() {
                            routines.clear();
                            _isRoutineDeleted = true;
                          });
                        },
                        messageHeader: '루틴 삭제',
                        message: '해당 카테고리를 삭제하시겠습니까?\n삭제 후 다시 추가할 수 있습니다.',
                      ),
                );
              },
              padding: EdgeInsets.only(right: 60),
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFFE04747),
              borderRadius: BorderRadius.circular(9),
              icon: Icons.delete,
              label: '삭제',
            ),
          ],
        ),
        startActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              onPressed: (_) {
                setState(() {
                  _isRoutineDeleted = false;
                });
              },
              foregroundColor: Colors.green,
              icon: Icons.restore,
              label: '복구',
            ),
          ],
        ),

        child: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
          ),
          child: ExpansionTileCard(
            elevation: 0,
            baseColor: Colors.white,
            expandedColor: Colors.white,
            borderRadius: BorderRadius.circular(9),
            contentPadding: EdgeInsets.zero,
            trailing: SizedBox.shrink(),

            title: Container(
              decoration: BoxDecoration(
                color: _isRoutineDeleted ? LIGHT_GREY_COLOR : Colors.white,
                borderRadius: BorderRadius.circular(9),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              height: 50,
              child: Row(
                children: [
                  Text(
                    'Routine',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'RubikSprayPaint',
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            children: <Widget>[
              Transform.translate(
                offset: Offset(-22, 0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...routines.map((routine) {
                        return RoutineCard(
                          key: ValueKey(routine.id),
                          content: routine.content,
                          showCheckbox: false,
                          deletePopupBuilder: (context) {
                            return DeletePopup(
                              onDelete: () {
                                setState(() {
                                  routines.removeWhere(
                                    (item) => item.id == routine.id,
                                  );
                                });
                              },
                              messageHeader: '삭제',
                              message: '해당 목록을 삭제할까요?',
                            );
                          },
                          onEdit: (newContent) {
                            setState(() {
                              final target = routines.firstWhere(
                                (item) => item.id == routine.id,
                              );
                              target.content = newContent;
                            });
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodoAccordion() {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Slidable(
        key: ValueKey('todoCategory'),
        endActionPane: ActionPane(
          motion: ScrollMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              onPressed: (context) {
                showDialog(
                  context: context,
                  builder:
                      (context) => DeletePopup(
                        onDelete: () {
                          setState(() {
                            todos.clear();
                            _isTodoDeleted = true;
                          });
                        },
                        messageHeader: '투두리스트 삭제',
                        message: '해당 카테고리를 삭제하시겠습니까?\n삭제 후 다시 추가할 수 있습니다.',
                      ),
                );
              },
              padding: EdgeInsets.only(right: 60),
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFFE04747),
              borderRadius: BorderRadius.circular(9),
              icon: Icons.delete,
              label: '삭제',
            ),
          ],
        ),
        startActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              onPressed: (_) {
                setState(() {
                  _isTodoDeleted = false;
                });
              },
              foregroundColor: Colors.green,
              icon: Icons.restore,
              label: '복구',
            ),
          ],
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
          ),
          child: ExpansionTileCard(
            elevation: 0,
            baseColor: Colors.white,
            expandedColor: Colors.white,
            borderRadius: BorderRadius.circular(9),
            contentPadding: EdgeInsets.zero,
            trailing: SizedBox.shrink(),

            title: Container(
              decoration: BoxDecoration(
                color: _isTodoDeleted ? LIGHT_GREY_COLOR : Colors.white,
                borderRadius: BorderRadius.circular(9),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              height: 50,
              child: Row(
                children: [
                  Text(
                    'To-Do list',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'RubikSprayPaint',
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            children: <Widget>[
              Transform.translate(
                offset: Offset(-22, 0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...todos.map((todo) {
                        return TodoCard(
                          key: ValueKey(todo.id),
                          content: todo.content,
                          showCheckbox: false,
                          deletePopupBuilder: (context) {
                            return DeletePopup(
                              onDelete: () {
                                setState(() {
                                  todos.removeWhere(
                                    (item) => item.id == todo.id,
                                  );
                                });
                              },
                              messageHeader: '삭제',
                              message: '해당 목록을 삭제할까요?',
                            );
                          },
                          onEdit: (newContent) {
                            setState(() {
                              final target = todos.firstWhere(
                                (item) => item.id == todo.id,
                              );
                              target.content = newContent;
                            });
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDaylogAccordion() {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Slidable(
        key: ValueKey('daylogCategory'),
        endActionPane: ActionPane(
          motion: ScrollMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              onPressed: (context) {
                showDialog(
                  context: context,
                  builder:
                      (context) => DeletePopup(
                        onDelete: () {
                          setState(() {
                            daylogQuestions.clear();
                            _isDaylogDeleted = true;
                          });
                        },
                        messageHeader: 'Day log 질문 삭제',
                        message: '해당 카테고리를 삭제하시겠습니까?\n삭제 후 다시 추가할 수 있습니다.',
                      ),
                );
              },
              padding: EdgeInsets.only(right: 60),
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFFE04747),
              borderRadius: BorderRadius.circular(9),
              icon: Icons.delete,
              label: '삭제',
            ),
          ],
        ),
        startActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              onPressed: (_) {
                setState(() {
                  _isDaylogDeleted = false;
                });
              },
              foregroundColor: Colors.green,
              icon: Icons.restore,
              label: '복구',
            ),
          ],
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
          ),
          child: ExpansionTileCard(
            key: _daylogTileKey,
            elevation: 0,
            baseColor: Colors.white,
            expandedColor: Colors.white,
            borderRadius: BorderRadius.circular(9),
            contentPadding: EdgeInsets.zero,
            trailing: SizedBox.shrink(),
            title: Container(
              decoration: BoxDecoration(
                color: _isDaylogDeleted ? LIGHT_GREY_COLOR : Colors.white,
                borderRadius: BorderRadius.circular(9),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              height: 50,
              child: Row(
                children: [
                  Text(
                    'Day log Question',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'RubikSprayPaint',
                      color: Colors.black,
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(-10, 0),
                    child: IconButton(
                      icon: Icon(Icons.error),
                      iconSize: 14.0,
                      onPressed: () {
                        Fluttertoast.showToast(
                          msg: "질문 개수는 최대 5까지 작성해주세요.",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          backgroundColor: Colors.black,
                          textColor: Colors.white,
                          fontSize: 8.0,
                        );
                      },
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all(
                          Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.add_circle, color: Colors.black),
                    onPressed: () {
                      if (daylogQuestions.length >= 5) {
                        Fluttertoast.showToast(
                          msg: "질문은 5개까지만 추가할 수 있어요.",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          backgroundColor: Colors.black,
                          textColor: Colors.white,
                          fontSize: 12.0,
                        );
                      } else {
                        setState(() {
                          _isAddingNewQuestion = true;
                          _newEmoji = '🙂';
                          _newQuestionController.clear();
                        });
                        _daylogTileKey.currentState?.expand();
                      }
                    },
                  ),
                ],
              ),
            ),
            children: <Widget>[
              Transform.translate(
                offset: Offset(0, -10),
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...daylogQuestions.map((question) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0, left: 5),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 260,
                                child: Text(
                                  question.content,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'PretendardRegular',
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return DeletePopup(
                                        onDelete: () {
                                          setState(() {
                                            daylogQuestions.removeWhere(
                                              (item) => item.id == question.id,
                                            );
                                          });
                                        },
                                        messageHeader: '삭제',
                                        message: '해당 목록을 삭제할까요?',
                                      );
                                    },
                                  );
                                },
                                child: SvgPicture.asset(
                                  'android/assets/images/routine_alarm.svg',
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),

                      if (_isAddingNewQuestion)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(),
                                    builder: (BuildContext context) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 24.0,
                                        ),
                                        child: SizedBox(
                                          height: 300,
                                          child: EmojiPicker(
                                            onEmojiSelected: (category, emoji) {
                                              setState(() {
                                                _newEmoji = emoji.emoji;
                                              });
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Text(
                                  _newEmoji,
                                  style: TextStyle(fontSize: 24),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _newQuestionController,
                                  decoration: InputDecoration(
                                    hintText: '질문을 입력하세요',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              IconButton(
                                icon: Icon(Icons.check),
                                onPressed: () {
                                  {
                                    setState(() {
                                      daylogQuestions.add(
                                        CategoryItem(
                                          id: uuid.v4(),
                                          content:
                                              '$_newEmoji ${_newQuestionController.text.trim()}',
                                        ),
                                      );
                                      _isAddingNewQuestion = false;
                                    });
                                  }
                                },
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
      ),
    );
  }

  Widget _buildDiaryIndex() {
    return Padding(
      padding: const EdgeInsets.only(left: 3),
      child: Slidable(
        key: ValueKey('diaryCategory'),
        endActionPane: ActionPane(
          motion: ScrollMotion(),
          extentRatio: 0.3,
          children: [
            SlidableAction(
              onPressed: (context) {
                showDialog(
                  context: context,
                  builder:
                      (context) => DeletePopup(
                        onDelete: () {
                          setState(() {
                            _isDiaryDeleted = true;
                          });
                        },
                        messageHeader: '일기 삭제',
                        message: '해당 카테고리를 삭제하시겠습니까?\n삭제 후 다시 추가할 수 있습니다.',
                      ),
                );
              },
              padding: EdgeInsets.only(left: 10),
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFFE04747),
              icon: Icons.delete,
              borderRadius: BorderRadius.circular(9),
              label: '삭제',
            ),
          ],
        ),
        startActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              onPressed: (_) {
                setState(() {
                  _isDiaryDeleted = false;
                });
              },
              padding: EdgeInsets.only(right: 0),
              foregroundColor: Colors.green,
              icon: Icons.restore,
              label: '복구',
            ),
          ],
        ),
        child: Container(
          width: 312,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: _isDiaryDeleted ? LIGHT_GREY_COLOR : Colors.white,
            borderRadius: BorderRadius.circular(9),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
            ],
          ),
          child: Center(
            child: Row(
              children: [
                SizedBox(width: 20.0),
                Text(
                  'Diary',
                  style: TextStyle(fontSize: 14, fontFamily: 'RubikSprayPaint'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
