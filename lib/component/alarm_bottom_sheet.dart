import 'package:flutter/material.dart';
import 'package:ohmo/component/alarm_setting.dart';
import '../db/drift_database.dart' as db;

class RoutineAlarm extends StatefulWidget {
  final int routineId;
  final VoidCallback? onDataChanged;

  const RoutineAlarm({Key? key, required this.routineId, this.onDataChanged})
    : super(key: key);

  @override
  State<RoutineAlarm> createState() => _RoutineAlarmState();
}

class TodoAlarm extends StatefulWidget {
  final DateTime currentDate;
  final int todoId;
  final VoidCallback? onDataChanged;

  const TodoAlarm({
    required this.currentDate,
    Key? key,
    required this.todoId,
    this.onDataChanged,
  }) : super(key: key);

  @override
  State<TodoAlarm> createState() => _TodoAlarmState();
}

class _RoutineAlarmState extends State<RoutineAlarm> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(30.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 20),
              _buildDeleteButton(),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return GestureDetector(
      onTap: () async {
        try {
          final database = db.LocalDatabaseSingleton.instance;

          await database.deleteRoutine(widget.routineId);

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("루틴이 삭제되었습니다.")));

          widget.onDataChanged?.call();

          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        } catch (e) {
          print('루틴 삭제 실패 : $e');
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('루틴 삭제에 실패했습니다.')));
        }
      },
      child: Container(
        width: 327,
        height: 56,
        decoration: BoxDecoration(
          color: Color(0xFFE04747),
          borderRadius: BorderRadius.circular(9),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
          ],
        ),
        child: Align(
          alignment: Alignment.center,
          child: Padding(
            padding: EdgeInsets.only(left: 16),
            child: Text(
              '삭제하기',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'PretendardBold',
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingRoutineAlarm() {
    return GestureDetector(
      onTap: () async {
        final result = await showModalBottomSheet<int>(
          context: context,
          isScrollControlled: true,
          isDismissible: true,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(59),
              topLeft: Radius.circular(59),
            ),
          ),
          builder: (BuildContext context) {
            return AlarmSetting();
          },
        );

        if (result != null) {
          Navigator.of(context).pop(result);
        }
      },
      child: Container(
        width: 318,
        height: 43,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
          ],
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 16),
            child: Text(
              '알람 시간 설정하기                                     >',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'PretendardRegular',
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TodoAlarmState extends State<TodoAlarm> {
  bool _isAlarmEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadTodoStatus();
  }

  Future<void> _loadTodoStatus() async {
    try {
      final todo = await db.LocalDatabaseSingleton.instance.getTodoById(
        widget.todoId,
      );
      if (mounted && todo != null) {
        setState(() {
          _isAlarmEnabled = todo.timeMinutes != null;
        });
      } else if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('투두 상태 로드 실패:$e');
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(30.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 20),
              _buildSettingNextDay(widget.currentDate),
              SizedBox(height: 7),
              if (_isAlarmEnabled) ...[
                _buildSettingRoutineAlarm(),
              ],
              SizedBox(height: 20),
              _buildDeleteButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return GestureDetector(
      onTap: () async {
        try {
          final database = db.LocalDatabaseSingleton.instance;

          await database.deleteTodo(widget.todoId);

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("투두가 삭제되었습니다.")));

          widget.onDataChanged?.call();

          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        } catch (e) {
          print('투두 삭제 실패 : $e');
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('투두 삭제에 실패했습니다.')));
        }
      },
      child: Container(
        width: 327,
        height: 56,
        decoration: BoxDecoration(
          color: Color(0xFFE04747),
          borderRadius: BorderRadius.circular(9),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
          ],
        ),
        child: Align(
          alignment: Alignment.center,
          child: Padding(
            padding: EdgeInsets.only(left: 16),
            child: Text(
              '삭제하기',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'PretendardBold',
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingNextDay(DateTime currentTodoDate) {
    return GestureDetector(
      onTap: () {
        final nextDay = currentTodoDate.add(const Duration(days: 1));
        Navigator.of(context).pop(nextDay);
      },
      child: Container(
        width: 318,
        height: 43,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
          ],
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 16),
            child: Text(
              '내일하기',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'PretendardRegular',
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingRoutineAlarm() {
    return GestureDetector(
      onTap: () async {
        final result = await showModalBottomSheet<int>(
          context: context,
          isScrollControlled: true,
          isDismissible: true,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(59),
              topLeft: Radius.circular(59),
            ),
          ),
          builder: (BuildContext context) {
            return AlarmSetting();
          },
        );
        if (result != null) {
          Navigator.of(context).pop(result);
        }
      },
      child: Container(
        width: 318,
        height: 43,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
          ],
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 16),
            child: Text(
              '미리 알림                                                  >',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'PretendardRegular',
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
