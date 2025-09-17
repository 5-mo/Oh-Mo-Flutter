import 'package:flutter/material.dart';
import 'package:ohmo/component/alarm_setting.dart';

class RoutineAlarm extends StatefulWidget {
  const RoutineAlarm({Key? key}) : super(key: key);

  @override
  State<RoutineAlarm> createState() => _RoutineAlarmState();
}

class TodoAlarm extends StatefulWidget {
  const TodoAlarm({Key? key}) : super(key: key);

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
              _buildSettingRoutineAlarm(),
              SizedBox(height: 50),
            ],
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
  DateTime selectedDate = DateTime.now();

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
              _buildSettingNextDay(),
              SizedBox(height: 7),
              _buildSettingDifferentDay(),
              SizedBox(height: 7),
              _buildSettingRoutineAlarm(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingNextDay() {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDate = DateTime.now().add(const Duration(days: 1));
        });
        print("${selectedDate.toLocal()}");
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

  Widget _buildSettingDifferentDay() {
    return GestureDetector(
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(3000),
          builder: (context, child) {
            return Theme(
              data: ThemeData.light().copyWith(
                primaryColor: Colors.black,
                colorScheme: const ColorScheme.light(primary: Colors.black),
                buttonTheme: const ButtonThemeData(
                  textTheme: ButtonTextTheme.primary,
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(foregroundColor: Colors.black),
                ),
              ),
              child: child!,
            );
          },
        );
        if (pickedDate != null && pickedDate != selectedDate) {
          setState(() {
            selectedDate = pickedDate;
          });
          print("선택한 날짜 : ${selectedDate.toLocal()}");
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
              '날짜 바꾸기                                                >',
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
      onTap: ()  async {
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
