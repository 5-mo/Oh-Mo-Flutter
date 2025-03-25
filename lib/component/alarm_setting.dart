import 'package:flutter/material.dart';
import 'package:ohmo/const/colors.dart';

class AlarmSetting extends StatefulWidget {
  const AlarmSetting({Key? key}) : super(key: key);

  @override
  State<AlarmSetting> createState() => _AlarmSettingState();
}

class _AlarmSettingState extends State<AlarmSetting> {
  String selectedMinute = "";
  bool isManualInputSelected = false;

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
              _buildAlarmTimeSetting(),
              if (isManualInputSelected) _buildManualInputField(),
              SizedBox(height: 30),
              _buildSaveButton(),
              SizedBox(height: bottomInset),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlarmTimeSetting() {
    List<String> minutes = ["5분 전", "10분 전", "15분 전", "20분 전", "직접 입력"];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "알람 시간 설정하기",
            style: TextStyle(fontSize: 16, fontFamily: 'PretendardBold'),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children:
                minutes
                    .map((minute) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: _buildMinuteButton(minute),
                      );
                    })
                    .toList()
                    .expand((widget) => [widget, SizedBox(width: 13)])
                    .toList()
                  ..removeLast(),
          ),
        ],
      ),
    );
  }

  Widget _buildMinuteButton(String minute) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (minute == "직접 입력") {
            isManualInputSelected = true;
            selectedMinute = minute;
          } else {
            selectedMinute = minute;
            isManualInputSelected = false;
            print("$minute 선택됨");
          }
        });
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selectedMinute == minute ? Colors.black : LIGHT_GREY_COLOR,
        ),
        child: Center(
          child: Text(
            minute,
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'PretendardRegular',
              color: selectedMinute == minute ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildManualInputField() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 37,
            height: 35,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 1),
              ],
            ),
            child: TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                counterText: "",
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(fontSize: 16, fontFamily: 'PretendardRegular'),
              maxLength: 2,
              textAlignVertical: TextAlignVertical.center,
            ),
          ),
          SizedBox(width: 8),
          Text(
            "분 전",
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'PretendardRegular',
              color: Colors.black,
            ),
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
