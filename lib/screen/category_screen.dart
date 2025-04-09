import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ohmo/component/delete_popup.dart';
import 'package:ohmo/component/routine_card.dart';
import 'package:ohmo/shared_data.dart';
import 'package:ohmo/component/todo_card.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
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
    return Container(
      width: 360,
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(9),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            height: 44,
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
    );
  }

  Widget _buildTodoAccordion() {
    return Container(
      width: 360,
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(9),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            height: 44,
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
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
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
                                todos.removeWhere((item) => item.id == todo.id);
                              });
                            },
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
    );
  }

  Widget _buildDaylogAccordion() {
    return Container(
      width: 360,
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(9),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            height: 44,
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
                      foregroundColor: MaterialStateProperty.all(Colors.black),
                    ),
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.add_circle),
                  onPressed: () {},
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all(Colors.black),
                  ),
                ),
              ],
            ),
          ),
          children: <Widget>[
            Transform.translate(
              offset: Offset(0, -10),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Transform.translate(
                  offset: Offset(-10, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        daylogQuestions.map((question) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width:250,
                                  child: Text(
                                    question.content,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'PretendardRegular',
                                    ),
                                    overflow:TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width:22),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return DeletePopup(
                                          onDelete: () {
                                            setState(() {
                                              daylogQuestions.removeWhere(
                                                (item) =>
                                                    item.id == question.id,
                                              );
                                            });
                                          },
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
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiaryIndex() {
    return Transform.translate(
      offset: Offset(2, 0),
      child: Container(
        width: 325,
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
              SizedBox(width: 20.0),
              Text(
                'Diary',
                style: TextStyle(fontSize: 14, fontFamily: 'RubikSprayPaint'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
