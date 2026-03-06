import 'package:flutter/material.dart';
import 'package:ohmo/component/alarm_setting.dart';
import 'package:ohmo/models/profile_data_provider.dart';
import 'package:ohmo/services/notification_service.dart';
import 'package:ohmo/services/routine_service.dart';
import 'package:ohmo/services/todo_service.dart';
import 'package:provider/provider.dart';
import '../db/drift_database.dart' as db;
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' as drift;

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
          final routineService = RoutineService();
          final profile = Provider.of<ProfileData>(context, listen: false);

          final routine = await database.getRoutineById(widget.routineId);
          final int? serverRoutineId = routine?.routineId;

          if (profile.isGuest) {
            await database.softDeleteRoutine(widget.routineId, profile.isGuest);
          } else {
            bool isServerSuccess = true;
            if (serverRoutineId != null && serverRoutineId != 0) {
              isServerSuccess = await routineService.deleteRoutine(
                serverRoutineId,
              );
            }

            if (isServerSuccess) {
              await database.deleteRoutine(widget.routineId);
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("서버 삭제에 실패했습니다. 다시 시도해주세요.")),
                );
              }
              return;
            }
          }

          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("루틴이 삭제되었습니다.")));
            widget.onDataChanged?.call();
            if (Navigator.canPop(context)) Navigator.pop(context);
          }
        } catch (e) {
          print('루틴 삭제 실패 : $e');
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
              if (_isAlarmEnabled) ...[_buildSettingTodoAlarm()],
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
          final todoService = TodoService();
          if (!mounted) return;
          final profile = Provider.of<ProfileData>(context, listen: false);

          if (profile.isGuest) {
            await (database.update(database.todos)
              ..where((t) => t.id.equals(widget.todoId))).write(
              const db.TodosCompanion(
                isDeleted: drift.Value(true),
                isSynced: drift.Value(false),
              ),
            );
          } else {
            final todo = await database.getTodoById(widget.todoId);
            final int? serverTodoId = todo?.todoServerId;

            if (serverTodoId != null && serverTodoId != 0) {
              bool isServerSuccess = await todoService.deleteTodo(serverTodoId);
              if (!isServerSuccess) throw Exception("서버 삭제 실패");
            }
            await database.deleteTodo(widget.todoId);
          }

          if (mounted) {
            widget.onDataChanged?.call();
            Navigator.of(context).pop();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("투두가 삭제되었습니다.")));
          }
        } catch (e) {
          print("삭제 중 에러 발생: $e");
        }
      },
      child: Container(
        width: 327,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFE04747),
          borderRadius: BorderRadius.circular(9),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
          ],
        ),
        child: const Center(
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
    );
  }

  String? convertMinutesToTime(int? minutes) {
    if (minutes == null) return null;
    final h = (minutes ~/ 60).toString().padLeft(2, '0');
    final m = (minutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  Widget _buildSettingNextDay(DateTime currentTodoDate) {
    return GestureDetector(
      onTap: () async {
        final profile = Provider.of<ProfileData>(context, listen: false);
        final nextDay = currentTodoDate.add(const Duration(days: 1));
        final nextDayString = DateFormat('yyyy-MM-dd').format(nextDay);
        final String weekdayName =
            DateFormat('EEEE').format(nextDay).toUpperCase();
        final database = db.LocalDatabaseSingleton.instance;

        try {
          var isSuccess = true;

          if (!profile.isGuest) {
            final todo = await database.getTodoById(widget.todoId);

            if (todo != null && todo.scheduleId != null) {
              isSuccess = await TodoService().updateTodo(
                scheduleId: todo.scheduleId!,
                categoryId: todo.categoryId ?? 3,
                content: todo.content,
                date: nextDayString,
                routineWeek: [weekdayName],
                time:
                    todo.timeMinutes != null
                        ? convertMinutesToTime(todo.timeMinutes)
                        : null,
              );
            } else {
              isSuccess = false;
              print("에러: scheduleId를 찾을 수 없습니다.");
            }
          }

          if (isSuccess) {
            await database.updateTodoDate(widget.todoId, nextDay);
            widget.onDataChanged?.call();

            if (mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("날짜가 변경되었습니다.")));
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("서버 업데이트에 실패했습니다.")));
            }
          }
        } catch (e) {
          print("내일하기 실행 중 에러 발생: $e");
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

  Widget _buildSettingTodoAlarm() {
    return GestureDetector(
      onTap: () async {
        final dbInstance = db.LocalDatabaseSingleton.instance;
        final profile = Provider.of<ProfileData>(context, listen: false);

        final todo = await dbInstance.getTodoById(widget.todoId);

        if (todo == null || todo.timeMinutes == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('시간이 설정된 투두만 알람을 켤 수 있습니다.')),
            );
          }
          return;
        }

        final resultMinutes = await showModalBottomSheet<int>(
          context: context,
          isScrollControlled: true,
          isDismissible: true,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(59),
              topLeft: Radius.circular(59),
            ),
          ),
          builder: (BuildContext context) {
            return const AlarmSetting();
          },
        );

        if (resultMinutes != null) {
          String? alarmTimeStr;
          DateTime? notificationTime;

          final DateTime baseTodoDate = DateTime(
            todo.date.year,
            todo.date.month,
            todo.date.day,
            todo.timeMinutes! ~/ 60,
            todo.timeMinutes! % 60,
          );

          if (resultMinutes > 0) {
            notificationTime = baseTodoDate.subtract(
              Duration(minutes: resultMinutes),
            );
            alarmTimeStr = DateFormat('HH:mm:ss').format(notificationTime);
          } else {
            alarmTimeStr = null;
          }

          try {
            final todoService = TodoService();
            var isSuccess = true;

            if (!profile.isGuest) {
              if (todo.scheduleId != null && todo.scheduleId != 0) {
                isSuccess = await todoService.updateAlarmTime(
                  todo.scheduleId!,
                  alarmTimeStr,
                );
              }
            }

            if (isSuccess) {
              await dbInstance.updateTodo(
                db.TodosCompanion(
                  id: drift.Value(widget.todoId),
                  alarmMinutes: drift.Value(
                    resultMinutes > 0 ? resultMinutes : null,
                  ),
                ),
              );

              await NotificationService().cancelNotification(todo.id);

              if (resultMinutes > 0 && notificationTime != null) {
                if (notificationTime.isAfter(DateTime.now())) {
                  await NotificationService().scheduleNotification(
                    id: todo.id,
                    title: '오늘의 할 일!',
                    body: '[To-do] ${todo.content}',
                    scheduledTime: notificationTime,
                    payload: 'todo_${todo.id}',
                  );
                  print('시스템 알람 예약 완료 : $notificationTime');
                }
              }

              widget.onDataChanged?.call();

              if (mounted) {
                String msg =
                    resultMinutes > 0 ? "알람이 설정되었습니다." : "알람이 해제되었습니다.";
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(msg)));
                Navigator.pop(context);
              }
            } else {
              if (mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("알람 설정에 실패했습니다.")));
              }
            }
          } catch (e) {
            print("에러: $e");
          }
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
