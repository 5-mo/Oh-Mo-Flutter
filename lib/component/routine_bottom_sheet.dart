import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:ohmo/const/colors.dart';

class RoutineBottomSheet extends StatefulWidget {
  const RoutineBottomSheet({Key? key}) : super(key: key);

  @override
  State<RoutineBottomSheet> createState() => _RoutineBottomSheetState();
}

class _RoutineBottomSheetState extends State<RoutineBottomSheet> {
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildAlarmToggleSection(),
                  _buildRoutineTimeButton(),
                ],
              ),
              _buildCategorySelectionSection(),
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
    List<String> days = ["월", "화", "수", "목", "금", "토", "일"];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "루틴 반복 요일",
            style: TextStyle(fontSize: 16, fontFamily: 'PretendardBold'),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children:
                days.map((day) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: _buildDayButton(day),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  List<String> selectedDays = [];

  Widget _buildDayButton(String day) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (selectedDays.contains(day)) {
            selectedDays.remove(day);
          } else {
            selectedDays.add(day);
          }
        });
        print('$day 클릭');
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selectedDays.contains(day) ? Colors.black : Colors.white,
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
              color: selectedDays.contains(day) ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  bool isChecked = false;

  Widget _buildAlarmToggleSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                "알람",
                style: TextStyle(fontSize: 14, fontFamily: 'PretendardRegular'),
              ),
              Transform.scale(
                scale: 0.8,
                child: CupertinoSwitch(
                  value: isChecked,
                  onChanged: (value) {
                    setState(() {
                      isChecked = value;
                    });
                    print("알람 상태 : $value");
                  },
                  activeColor: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  TimeOfDay? selectedTime;

  Widget _buildRoutineTimeButton() {
    return GestureDetector(
      onTap: () async {
        TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: selectedTime ?? TimeOfDay.now(),
          builder: (BuildContext context, Widget? child) {
            return Theme(
              data: ThemeData(
                primaryColor: LIGHT_GREY_COLOR,
                timePickerTheme: TimePickerThemeData(
                  hourMinuteColor: Colors.grey[200],
                  hourMinuteTextColor: Colors.black,
                  backgroundColor: Colors.white,
                  dialHandColor: Colors.black,
                  dialBackgroundColor: Colors.grey[200],
                  dayPeriodColor: Colors.grey[200],
                  dayPeriodTextColor: Colors.black,
                ),
              ),
              child: child!,
            );
          },
        );

        if (pickedTime != null) {
          setState(() {
            selectedTime = pickedTime;
          });
        }
      },
      child: Container(
        width: 195,
        height: 37,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
          ],
        ),
        child: Center(
          child: Center(
            child: Text(
              selectedTime != null ? selectedTime!.format(context) : '시간 선택',
              style: TextStyle(fontSize: 14, fontFamily: 'PretendardRegular'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelectionSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "카테고리",
            style: TextStyle(fontSize: 16, fontFamily: 'PretendardBold'),
          ),
          SizedBox(height: 16),
          Center(
            child: Text(
              "루틴 카테고리를 설정해볼까요?",
              style: TextStyle(
                fontSize: 10,
                fontFamily: 'PretendardSemiBold',
                color: DARK_GREY_COLOR,
              ),
            ),
          ),
          SizedBox(height: 16),
          Center(child: _buildCategoryButton()),
          SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.center),
        ],
      ),
    );
  }

  Widget _buildCategoryButton() {
    return GestureDetector(
      onTap: () {
        print('카테고리 클릭');
      },
      child: Container(
        width: 97,
        height: 18,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
          ],
        ),
        child: Center(
          child: Center(
            child: Text(
              '카테고리 추가하기',
              style: TextStyle(fontSize: 10, fontFamily: 'PretendardRegular'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentInputSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "내용",
            style: TextStyle(fontSize: 16, fontFamily: 'PretendardBold'),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Container(
                  width: 327,
                  height: 41,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: TextField(
                      decoration: InputDecoration(border: InputBorder.none),
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

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: () {
        print('저장하기');
      },
      child: Container(
        width: 327,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Center(
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
