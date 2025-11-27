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
  final TextEditingController _manualInputController = TextEditingController();

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
              SizedBox(height: 10),
              _buildDeleteAlarm(),
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
            "미리 알람",
            style: TextStyle(fontSize: 16, fontFamily: 'PretendardBold'),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: 20),
              ...minutes
                  .map((minute) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 0),
                      child: _buildMinuteButton(minute),
                    );
                  })
                  .toList()
                  .expand((widget) => [widget, SizedBox(width: 10)])
                  .toList()
                ..removeLast(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMinuteButton(String minute) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMinute = minute;
          if (minute == "직접 입력") {
            isManualInputSelected = true;
          } else {
            isManualInputSelected = false;
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
              controller: _manualInputController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                counterText: "",
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 0,
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
        if (isManualInputSelected) {
          final minutes = int.tryParse(_manualInputController.text);
          if (minutes != null) {
            Navigator.of(context).pop(minutes);
          } else {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('숫자만 입력해주세요.')));
          }
        }
        else if(selectedMinute.isNotEmpty){
          try{
            final minutes=int.parse(selectedMinute.replaceAll('분 전', ''));
            Navigator.of(context).pop(minutes);
          }catch(e){
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('값을 선택해주세요.')));
          }
        }
        else{
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('알람 시간을 선택해주세요.')));
        }
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

  Widget _buildDeleteAlarm() {
    return GestureDetector(
      onTap: () async {
        Navigator.of(context).pop(0);
      },
      child: Container(
        width: 327,
        height: 43,
        decoration: BoxDecoration(
          color: Colors.white,
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
              '미리 알림 삭제',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'PretendardBold',
                color: Color(0xFFC41E1E),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
