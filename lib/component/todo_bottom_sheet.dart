import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:ohmo/const/colors.dart';

class TodoBottomSheet extends StatefulWidget {
  const TodoBottomSheet({Key? key}) : super(key: key);

  @override
  State<TodoBottomSheet> createState() => _TodoBottomSheetState();
}

class _TodoBottomSheetState extends State<TodoBottomSheet> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(30.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  _buildDateSection(),
                  SizedBox(height: 16),
                  _buildTodoTimeButton(),
                  SizedBox(height: 16),
                  _buildCategorySelectionSection(),
                  _buildContentInputSection(),
                  SizedBox(height: 20),
                  _buildSaveButton(),
                  SizedBox(height: bottomInset),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "날짜 및 시간",
            style: TextStyle(fontSize: 16, fontFamily: 'PretendardBold'),
          ),
          SizedBox(height: 16),
          _buildAlarmToggleSection(),
        ],
      ),
    );
  }

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
                scale: 1,
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

  Widget _buildTodoTimeButton() {
    String todayDate = "${DateTime.now().month}월   ${DateTime.now().day}일";
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          todayDate,
          style: TextStyle(fontSize: 16, fontFamily: 'PretendardRegular'),
        ),
        GestureDetector(
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
                  selectedTime != null
                      ? selectedTime!.format(context)
                      : '시간 선택',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'PretendardRegular',
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
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
                  width: 334,
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
        width: 334,
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
