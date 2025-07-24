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
import '../component/color_palette_bottom_sheet.dart';
import 'package:ohmo/services/category_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../customize_category.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<CategoryItem> routines = [];
  List<CategoryItem> todos = [];
  int? selectedCategoryId;

  String _newEmoji = '🙂';
  TextEditingController _newQuestionController = TextEditingController();
  TextEditingController _newRoutineController = TextEditingController();
  TextEditingController _newTodoController = TextEditingController();

  bool _isAddingNewQuestion = false;
  bool _isAddingNewRoutine = false;
  bool _isAddingNewTodo = false;
  final GlobalKey<ExpansionTileCardState> _daylogTileKey = GlobalKey();
  final GlobalKey<ExpansionTileCardState> _todoCardKey = GlobalKey();
  final GlobalKey<ExpansionTileCardState> _routineTileKey = GlobalKey();

  bool _isRoutineDeleted = false;
  bool _isTodoDeleted = false;
  bool _isDaylogDeleted = false;
  bool _isDiaryDeleted = false;

  ColorType _selectedColorType = ColorType.pinkLight;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadTodoCategories();
  }

  void _loadCategories() async {
    try {
      final accessToken = await getAccessToken();
      if (accessToken == null) {
        print('토큰 없음');
        return;
      }
      final fetched = await CategoryService.fetchCategories(
        scheduleType: 'ROUTINE',
        accessToken: accessToken,
      );

      setState(() {
        routines = fetched;

        if (routines.isNotEmpty) {
          selectedCategoryId = routines.first.id;
        }
      });
    } catch (e) {
      print('카테고리 로드 실패: $e');
    }
  }

  void _loadTodoCategories() async {
    try {
      final accessToken = await getAccessToken();
      if (accessToken == null) {
        print('토큰 없음');
        return;
      }
      final todofetched = await CategoryService.fetchCategories(
        scheduleType: 'TO_DO',
        accessToken: accessToken,
      );

      setState(() {
        todos = todofetched;
      });
    } catch (e) {
      print('카테고리 로드 실패: $e');
    }
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
                        onDelete: () async {
                          await RoutineVisibilityHelper.setVisibility(false);
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('isRoutineDeleted', true);
                          Navigator.pop(context, true);
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
              onPressed: (_) async {
                await RoutineVisibilityHelper.setVisibility(true);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isRoutineDeleted', false);
                Navigator.pop(context, true);
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
            key: _routineTileKey,
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Routine',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'RubikSprayPaint',
                      color: Colors.black,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle, color: Colors.black),
                    onPressed: () {
                      setState(() {
                        _isAddingNewRoutine = true;
                        _newRoutineController.clear();
                        _selectedColorType = ColorType.pinkLight;
                      });
                      _routineTileKey.currentState?.expand();
                    },
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
                          colorType: ColorTypeExtension.fromString(
                            routine.colorType,

                          ),
                          showCheckbox: false,
                          isDone: false,
                          scheduleId: routine.id,
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

                      if (_isAddingNewRoutine)
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 12,
                            bottom: 12,
                            right: 5,
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => _openColorPicker(context),
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: ColorManager.getColor(
                                      _selectedColorType,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _newRoutineController,
                                  decoration: InputDecoration(
                                    hintText: '루틴을 입력하세요',
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
                                onPressed: () async {
                                  final newText =
                                      _newRoutineController.text.trim();
                                  if (newText.isEmpty) return;

                                  final token = await getAccessToken();
                                  if (token == null) return;

                                  try {
                                    final newItem =
                                        await CategoryService.registerCategory(
                                          name: newText,
                                          color: _selectedColorType.name,
                                          scheduleType: 'ROUTINE',
                                          accessToken: token,
                                        );
                                    setState(() {
                                      routines.add(newItem);
                                      _isAddingNewRoutine = false;
                                      _newRoutineController.clear();
                                    });
                                  } catch (e) {
                                    print('루틴 등록 실패: $e');
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
                        onDelete: () async {
                          await TodoVisibilityHelper.setVisibility(false);
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('isTodoDeleted', true);
                          Navigator.pop(context, true);
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
              onPressed: (_) async {
                await TodoVisibilityHelper.setVisibility(true);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isTodoDeleted', false);
                Navigator.pop(context, true);
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
            key: _todoCardKey,
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
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.add_circle, color: Colors.black),
                    onPressed: () {
                      setState(() {
                        _isAddingNewTodo = true;
                        _newTodoController.clear();
                        _selectedColorType = ColorType.pinkLight;
                      });
                      _todoCardKey.currentState?.expand();
                    },
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
                          scheduleId: todo.id,
                        colorType: ColorTypeExtension.fromString(
                        todo.colorType,
                        ),
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
                          }, isDone: false,
                        );
                      }),
                      if (_isAddingNewTodo)
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 12,
                            bottom: 12,
                            right: 5,
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => _openColorPicker(context),
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: ColorManager.getColor(
                                      _selectedColorType,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _newTodoController,
                                  decoration: InputDecoration(
                                    hintText: '투두를 입력하세요',
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
                                onPressed: () async {
                                  final newText =
                                      _newTodoController.text.trim();
                                  if (newText.isEmpty) return;

                                  final token = await getAccessToken();
                                  if (token == null) return;

                                  try {
                                    final newItem =
                                        await CategoryService.registerCategory(
                                          name: newText,
                                          color: _selectedColorType.name,
                                          scheduleType: 'TO_DO',
                                          accessToken: token,
                                        );
                                    setState(() {
                                      todos.add(newItem);
                                      _isAddingNewTodo = false;
                                      _newTodoController.clear();
                                    });
                                  } catch (e) {
                                    print('루틴 등록 실패: $e');
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
                        onDelete: () async {
                          await QuestionVisibilityHelper.setVisibility(false);
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('isQuestionDeleted', true);
                          Navigator.pop(context, true);
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
              onPressed: (_) async {
                await QuestionVisibilityHelper.setVisibility(true);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isQuestionDeleted', false);
                Navigator.pop(context, true);
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
                                        ICategoryItem(
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
                        onDelete: () async {
                          await DiaryVisibilityHelper.setVisibility(false);
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('isDiaryDeleted', true);
                          Navigator.pop(context, true);
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
              onPressed: (_) async {
                await DiaryVisibilityHelper.setVisibility(true);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isDiaryDeleted', false);
                Navigator.pop(context, true);
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

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  void _openColorPicker(BuildContext context) {
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
  }
}
