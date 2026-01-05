import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ohmo/component/delete_popup.dart';
import 'package:ohmo/component/category_routine_card.dart';
import 'package:ohmo/const/colors.dart';
import 'package:ohmo/db/local_category_repository.dart';
import 'package:ohmo/component/category_todo_card.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:ohmo/screen/group/group_main_screen.dart';
import '../component/color_palette_bottom_sheet.dart';
import '../component/group_settings_bottom_sheet.dart';
import '../customize_category.dart';
import 'package:uuid/uuid.dart';
import 'package:ohmo/db/drift_database.dart'
    show LocalDatabase, LocalDatabaseSingleton, Group;
import 'package:ohmo/models/category_item.dart';
import 'package:ohmo/services/category_service.dart';
import 'group/group_sign_screen.dart';
import 'package:intl/intl.dart';
import '../services/day_log_service.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  static const currentUserId = 1; //db 연결
  List<CategoryItem> routines = [];
  List<CategoryItem> todos = [];
  List<DayLogQuestionItem> daylogQuestions = [];
  int? selectedCategoryId;
  bool _needsRefresh = false;

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
  final GlobalKey<ExpansionTileCardState> _groupTileKey = GlobalKey();

  bool _isRoutineDeleted = false;
  bool _isTodoDeleted = false;
  bool _isDaylogDeleted = false;
  bool _isDiaryDeleted = false;
  bool _isGroupDeleted = false;

  ColorType _selectedColorType = ColorType.pinkLight;

  late LocalCategoryRepository _repository;
  late LocalDatabase _db;
  List<Group> _groups = [];

  final uuid = Uuid();
  final CategoryService _categoryService = CategoryService();

  @override
  void initState() {
    super.initState();
    _db = LocalDatabaseSingleton.instance;
    _repository = LocalCategoryRepository(_db);
    _loadAllData();
  }

  void _loadAllData() async {
    final currentLocalQuestions = await _repository.fetchDayLogQuestions();
    final Set<String> existingContents =
        currentLocalQuestions.map((q) => q.question.trim()).toSet();

    final List<Map<String, String>> defaultQuestions = [
      {'emoji': '💰', 'text': '오늘의 소비는?'},
      {'emoji': '😊', 'text': '오늘의 내가 감사했던 일은?'},
    ];

    for (var defaultQ in defaultQuestions) {
      final String content = defaultQ['text']!.trim();
      final String emoji = defaultQ['emoji']!;

      if (!existingContents.contains(content)) {
        await _repository.insertDayLogQuestion(content, emoji);
        existingContents.add(content);
      }
    }

    final dayLogService = DayLogService();
    final serverQuestions = await dayLogService.getQuestions();

    if (serverQuestions != null && serverQuestions.isNotEmpty) {
      for (var serverQ in serverQuestions) {
        final String content = serverQ['questionContent'] ?? '';
        final String emoji = serverQ['emoji'] ?? '';

        if (!existingContents.contains(content)) {
          await _repository.insertDayLogQuestion(content, emoji);

          existingContents.add(content);
        }
      }
    }

    final fetchedRoutines = await _repository.fetchCategories(
      scheduleType: 'ROUTINE',
    );
    final filteredRoutines =
        fetchedRoutines.where((c) => c.categoryName != 'default').toList();
    final fetchedTodos = await _repository.fetchCategories(
      scheduleType: 'TO_DO',
    );
    final filteredTodos =
        fetchedTodos.where((c) => c.categoryName != 'default').toList();
    List<DayLogQuestionItem> allFetchedDaylogs =
        await _repository.fetchDayLogQuestions();

    final Set<String> seenQuestions = {};
    final List<DayLogQuestionItem> uniqueDaylogs = [];

    for (var question in allFetchedDaylogs) {
      final trimmedText = question.question.trim();
      if (!seenQuestions.contains(trimmedText)) {
        seenQuestions.add(trimmedText);
        uniqueDaylogs.add(question);
      }
    }

    final fetchedGroups = await _db.getGroupsForUser(currentUserId);

    final isRoutineVisible = await RoutineVisibilityHelper.getVisibility();
    final isTodoVisible = await TodoVisibilityHelper.getVisibility();
    final isDaylogVisible = await QuestionVisibilityHelper.getVisibility();
    final isDiaryVisible = await DiaryVisibilityHelper.getVisibility();
    final isGroupVisible = await GroupVisibilityHelper.getVisibility();

    if (mounted) {
      setState(() {
        routines = filteredRoutines;
        todos = filteredTodos;
        daylogQuestions = uniqueDaylogs;
        _groups = fetchedGroups;
        if (routines.isNotEmpty) selectedCategoryId = routines.first.id;

        _isRoutineDeleted = !isRoutineVisible;
        _isTodoDeleted = !isTodoVisible;
        _isDaylogDeleted = !isDaylogVisible;
        _isDiaryDeleted = !isDiaryVisible;
        _isGroupDeleted = !isGroupVisible;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        Navigator.pop(context, _needsRefresh);
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
          backgroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 30, left: 30),
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
              SizedBox(height: 10.0),

              Padding(
                padding: const EdgeInsets.only(left: 31),
                child: _buildGroupAccordion(),
              ),
              SizedBox(height: 60),
            ],
          ),
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
      padding: const EdgeInsets.only(right: 5),
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
                          if (mounted) {
                            setState(() {
                              _isRoutineDeleted = true;
                              _needsRefresh = true;
                            });
                          }
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
                if (mounted) {
                  setState(() {
                    _isRoutineDeleted = false;
                    _needsRefresh = true;
                  });
                }
              },
              foregroundColor: Colors.green,
              icon: Icons.restore,
              label: '복구',
            ),
          ],
        ),
        child: IgnorePointer(
          ignoring: _isRoutineDeleted,
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
                          return CategoryRoutineCard(
                            key: ValueKey(routine.id),
                            content: routine.categoryName,
                            colorType: ColorTypeExtension.fromString(
                              routine.colorType,
                            ),
                            isColorPickerEnabled: true,
                            scheduleId: routine.id,
                            deletePopupBuilder: (context) {
                              return DeletePopup(
                                onDelete: () async {
                                  await _repository.deleteCategory(routine.id);
                                  setState(() {
                                    routines.removeWhere(
                                      (item) => item.id == routine.id,
                                    );
                                    _needsRefresh = true;
                                  });
                                },
                                messageHeader: '삭제',
                                message: '해당 목록을 삭제할까요?',
                              );
                            },
                            onEdit: (newContent) async {
                              await _repository.updateCategoryName(
                                routine.id,
                                newContent,
                              );
                              setState(() {
                                routine.categoryName = newContent;
                                _needsRefresh = true;
                              });
                            },
                            onDataChanged: () {
                              setState(() {
                                _loadAllData();
                                _needsRefresh = true;
                              });
                            },
                          );
                        }).toList(),

                        if (_isAddingNewRoutine)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 12,
                              bottom: 12,
                              right: 5,
                              left: 5,
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

                                    final int? serverId = await _categoryService
                                        .createCategory(
                                          categoryName: newText,
                                          color:
                                              _selectedColorType.name
                                                  .toUpperCase(),
                                          scheduleType: 'ROUTINE',
                                        );

                                    if (serverId == null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text("서버 저장 실패")),
                                      );
                                      return;
                                    }

                                    final newItem = await _repository
                                        .insertCategory(
                                          name: newText,
                                          type: 'ROUTINE',
                                          color: _selectedColorType.name,
                                        );
                                    setState(() {
                                      routines.add(newItem);
                                      _isAddingNewRoutine = false;
                                      _newRoutineController.clear();
                                      _needsRefresh = true;
                                    });
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
      ),
    );
  }

  Widget _buildTodoAccordion() {
    return Padding(
      padding: const EdgeInsets.only(right: 7),
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
                          if (mounted) {
                            setState(() {
                              _isTodoDeleted = true;
                              _needsRefresh = true;
                            });
                          }
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
                if (mounted) {
                  setState(() {
                    _isTodoDeleted = false;
                    _needsRefresh = true;
                  });
                }
              },
              foregroundColor: Colors.green,
              icon: Icons.restore,
              label: '복구',
            ),
          ],
        ),
        child: IgnorePointer(
          ignoring: _isTodoDeleted,
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
                          return CategoryTodoCard(
                            key: ValueKey(todo.id),
                            onDataChanged: () => _loadAllData(),
                            content: todo.categoryName,
                            scheduleId: todo.id,
                            colorType: ColorTypeExtension.fromString(
                              todo.colorType,
                            ),
                            isColorPickerEnabled: true,
                            deletePopupBuilder: (context) {
                              return DeletePopup(
                                onDelete: () async {
                                  await _repository.deleteCategory(todo.id);
                                  setState(() {
                                    todos.removeWhere(
                                      (item) => item.id == todo.id,
                                    );
                                    _needsRefresh = true;
                                  });
                                },
                                messageHeader: '삭제',
                                message: '해당 목록을 삭제할까요?',
                              );
                            },
                            onEdit: (newContent) async {
                              await _repository.updateCategoryName(
                                todo.id,
                                newContent,
                              );
                              setState(() {
                                todo.categoryName = newContent;
                                _needsRefresh = true;
                              });
                            },
                          );
                        }).toList(),

                        if (_isAddingNewTodo)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 12,
                              bottom: 12,
                              left: 5,
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
                                SizedBox(width: 15),
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

                                    final int? serverId = await _categoryService
                                        .createCategory(
                                          categoryName: newText,
                                          color:
                                              _selectedColorType.name
                                                  .toUpperCase(),
                                          scheduleType: "TO_DO",
                                        );

                                    if (serverId == null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text("서버 저장 실패")),
                                      );
                                      return;
                                    }

                                    final newItem = await _repository
                                        .insertCategory(
                                          name: newText,
                                          type: 'TO_DO',
                                          color: _selectedColorType.name,
                                        );
                                    setState(() {
                                      todos.add(newItem);
                                      _isAddingNewTodo = false;
                                      _newTodoController.clear();
                                      _needsRefresh = true;
                                    });
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
      ),
    );
  }

  Widget _buildDaylogAccordion() {
    return Padding(
      padding: const EdgeInsets.only(right: 7),
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

                          if (mounted) {
                            setState(() {
                              _isDaylogDeleted = true;
                              _needsRefresh = true;
                            });
                          }
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
                if (mounted) {
                  setState(() {
                    _isDaylogDeleted = false;
                    _needsRefresh = true;
                  });
                }
              },
              foregroundColor: Colors.green,
              icon: Icons.restore,
              label: '복구',
            ),
          ],
        ),
        child: IgnorePointer(
          ignoring: _isDaylogDeleted,
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
                            padding: const EdgeInsets.only(
                              bottom: 8.0,
                              left: 11,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 260,
                                  child: Row(
                                    children: [
                                      Text(
                                        question.emoji,
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          question.question,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: 'PretendardRegular',
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return DeletePopup(
                                          onDelete: () async {
                                            await _repository
                                                .deleteDayLogQuestion(
                                                  question.id,
                                                );
                                            setState(() {
                                              daylogQuestions.removeWhere(
                                                (item) =>
                                                    item.id == question.id,
                                              );
                                              _needsRefresh = true;
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
                            padding: const EdgeInsets.only(
                              bottom: 12.0,
                              right: 45,
                              left: 10,
                            ),
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
                                              onEmojiSelected: (
                                                category,
                                                emoji,
                                              ) {
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
                                IconButton(
                                  icon: Icon(Icons.check),
                                  onPressed: () async {
                                    final newText =
                                        _newQuestionController.text.trim();
                                    if (newText.isEmpty) return;

                                    final dayLogService = DayLogService();

                                    final bool isApiSuccess =
                                        await dayLogService.registerQuestion(
                                          questionContent: newText,
                                          emoji: _newEmoji,
                                        );

                                    if (!isApiSuccess) {
                                      print("질문 서버 등록 실패");
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text("서버 저장에 실패했습니다."),
                                        ),
                                      );
                                      return;
                                    }

                                    final newItem = await _repository
                                        .insertDayLogQuestion(
                                          newText,
                                          _newEmoji,
                                        );
                                    if (mounted) {
                                      setState(() {
                                        daylogQuestions.add(newItem);
                                        _isAddingNewQuestion = false;
                                        _newQuestionController.clear();
                                        _needsRefresh = true;
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
      ),
    );
  }

  Widget _buildGroupSection({required Group group}) {
    final Color color = ColorManager.getColor(
      ColorType.values[group.colorType],
    );
    return InkWell(
      onTap: () async {
        final bool? needsRefresh = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => GroupMainScreen(groupId: group.id),
          ),
        );
        if (needsRefresh == true) {
          _loadAllData();
        }
      },
      child: Container(
        width: 150,
        height: 111,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.4),
              spreadRadius: 1,
              blurRadius: 1,
            ),
          ],
        ),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 140,
                  height: 70,
                  margin: const EdgeInsets.only(top: 5),
                  padding: const EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.4),
                        spreadRadius: 1,
                        blurRadius: 1,
                      ),
                    ],
                  ),
                  child: Text(
                    group.name.replaceAll(' ', '\n'),
                    style: TextStyle(
                      fontFamily: 'PretendardMedium',
                      fontSize: 12,
                      color: const Color(0xFF000000),
                    ),
                  ),
                ),
                Positioned(
                  top: 17,
                  right: 7,
                  child: GestureDetector(
                    onTap: () async {
                      final bool? needsRefresh =
                          await showModalBottomSheet<bool>(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(59),
                                topLeft: Radius.circular(59),
                              ),
                            ),
                            builder: (BuildContext bContext) {
                              return GroupSettingsBottomSheet(
                                groupId: group.id,
                              );
                            },
                          );
                      if (needsRefresh == true) {
                        _loadAllData();
                      }
                    },
                    child: Container(
                      color: Colors.transparent,
                      padding: const EdgeInsets.all(8.0),
                      child: SvgPicture.asset(
                        'android/assets/images/routine_alarm.svg',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildMemberProfile(
                    'android/assets/images/clear_ohmo.png',
                    0.8,
                    color,
                  ),
                  const SizedBox(width: 4),
                  _buildMemberProfile(
                    'android/assets/images/clear_ohmo.png',
                    0.5,
                    color,
                  ),
                  const SizedBox(width: 4),
                  _buildMemberProfile(
                    'android/assets/images/clear_ohmo.png',
                    1.0,
                    color,
                  ),
                  const SizedBox(width: 4),
                  _buildMemberProfile(
                    'android/assets/images/clear_ohmo.png',
                    0.2,
                    color,
                  ),
                  const SizedBox(width: 4),
                  _buildMemberProfile(
                    'android/assets/images/clear_ohmo.png',
                    0.2,
                    color,
                  ),
                  const SizedBox(width: 5),
                  _buildMemberProfile(
                    'android/assets/images/clear_ohmo.png',
                    0.2,
                    color,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateGroupCard() {
    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GroupSignScreen()),
        );
        _loadAllData();
      },
      child: Container(
        width: 150,
        height: 111,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.4),
              spreadRadius: 1,
              blurRadius: 1,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 140,
              height: 70,
              margin: const EdgeInsets.only(top: 5),
              padding: const EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.4),
                    spreadRadius: 1,
                    blurRadius: 1,
                  ),
                ],
              ),
              child: Text(
                '그룹\n만들기',
                style: TextStyle(
                  fontFamily: 'PretendardMedium',
                  fontSize: 12,
                  color: const Color(0xFF7B7B7B),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 9, horizontal: 8),
                child: Icon(Icons.add, size: 17, color: Color(0xFF7B7B7B)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberProfile(
    String imagePath,
    double progress,
    Color groupColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 3,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(radius: 8, backgroundImage: AssetImage(imagePath)),
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 3,
              backgroundColor: Color(0xFFA5A5A5),
              valueColor: AlwaysStoppedAnimation<Color>(groupColor),
            ),
          ),
        ],
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
                          if (mounted) {
                            setState(() {
                              _isDiaryDeleted = true;
                              _needsRefresh = true;
                            });
                          }
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
                if (mounted) {
                  setState(() {
                    _isDiaryDeleted = false;
                    _needsRefresh = true;
                  });
                }
              },
              foregroundColor: Colors.green,
              icon: Icons.restore,
              label: '복구',
            ),
          ],
        ),
        child: Container(
          width: 320,
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

  Widget _buildGroupAccordion() {
    return Padding(
      padding: const EdgeInsets.only(right: 7),
      child: Slidable(
        key: ValueKey('groupCategory'),
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
                          await GroupVisibilityHelper.setVisibility(false);
                          if (mounted) {
                            setState(() {
                              _isGroupDeleted = true;
                              _needsRefresh = true;
                            });
                          }
                        },
                        messageHeader: '그룹 섹션 삭제',
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
        // [추가] 복구 액션 (왼쪽 스와이프)
        startActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              onPressed: (_) async {
                await GroupVisibilityHelper.setVisibility(true);
                if (mounted) {
                  setState(() {
                    _isGroupDeleted = false;
                    _needsRefresh = true;
                  });
                }
              },
              foregroundColor: Colors.green,
              icon: Icons.restore,
              label: '복구',
            ),
          ],
        ),
        child: IgnorePointer(
          ignoring: _isGroupDeleted,
          child: Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
            ),
            child: ExpansionTileCard(
              key: _groupTileKey,
              elevation: 0,
              baseColor: Colors.white,
              expandedColor: Colors.white,
              borderRadius: BorderRadius.circular(9),
              contentPadding: EdgeInsets.zero,
              trailing: SizedBox.shrink(),
              title: Container(
                decoration: BoxDecoration(
                  color: _isGroupDeleted ? LIGHT_GREY_COLOR : Colors.white,
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
                      'Group',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'RubikSprayPaint',
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add_circle, color: Colors.black),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GroupSignScreen(),
                          ),
                        );
                        _loadAllData();
                      },
                    ),
                  ],
                ),
              ),
              children: <Widget>[
                Transform.translate(
                  offset: Offset(-10, 0),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 15.0,
                      bottom: 20.0,
                      left: 12.0,
                    ),
                    child: Container(
                      width: double.infinity,
                      child: Wrap(
                        spacing: 20.0,
                        runSpacing: 23.0,
                        alignment: WrapAlignment.start,
                        children: [
                          ..._groups.map((group) {
                            return _buildGroupSection(group: group);
                          }).toList(),
                          if (_groups.isEmpty) _buildCreateGroupCard(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
