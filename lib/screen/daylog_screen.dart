import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DaylogScreen extends StatefulWidget {
  @override
  _DaylogScreenState createState() => _DaylogScreenState();
}

class _DaylogScreenState extends State<DaylogScreen> {
  DateTime _focusedDay = DateTime.now();

  bool _happyActive = false;
  bool _sosoActive = false;
  bool _badActive = false;

  void _onLeftChevronPressed() {
    setState(() {
      _focusedDay = _focusedDay.subtract(Duration(days: 1));
    });
  }

  void _onRightChevronPressed() {
    setState(() {
      _focusedDay = _focusedDay.add(Duration(days: 1));
    });
  }

  void _onIconPressed(String iconName) {
    setState(() {
      if (iconName == 'happy_unselected') {
        _happyActive = !_happyActive;
        _sosoActive = false;
        _badActive = false;
      } else if (iconName == 'soso_unselected') {
        _sosoActive = !_sosoActive;
        _happyActive = false;
        _badActive = false;
      } else if (iconName == 'bad_unselected') {
        _badActive = !_badActive;
        _happyActive = false;
        _sosoActive = false;
      }
    });

    print("Clicked : $iconName");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [SizedBox(height: 70), _buildHeader()]),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: _onLeftChevronPressed,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Transform.translate(
                offset: Offset(40, 15),
                child: Text(
                  DateFormat('MMM').format(_focusedDay).toUpperCase(),
                  style: TextStyle(
                    fontSize: 22.0,
                    fontFamily: 'RubikSprayPaint',
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(40, 5),
                child: Text(
                  DateFormat('dd').format(_focusedDay),
                  style: TextStyle(
                    fontSize: 45.0,
                    fontFamily: 'RubikSprayPaint',
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(40, -5),
                child: Text(
                  DateFormat('E').format(_focusedDay).toUpperCase(),
                  style: TextStyle(
                    fontSize: 22.0,
                    fontFamily: 'RubikSprayPaint',
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: [
              Transform.translate(
                offset: Offset(-20, 0),
                child: GestureDetector(
                  onTap: () => _onIconPressed('happy_unselected'),
                  child: SvgPicture.asset(
                    'android/assets/images/happy_unselected.svg',
                    color: _happyActive ? Colors.black : Colors.grey,
                    height: 35.0,
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(-20, 0),
                child: GestureDetector(
                  onTap: () => _onIconPressed('soso_unselected'),
                  child: SvgPicture.asset(
                    'android/assets/images/soso_unselected.svg',
                    color: _sosoActive ? Colors.black : Colors.grey,
                    height: 35.0,
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(-20, 0),
                child: GestureDetector(
                  onTap: () => _onIconPressed('bad_unselected'),
                  child: SvgPicture.asset(
                    'android/assets/images/bad_unselected.svg',
                    color: _badActive ? Colors.black : Colors.grey,
                    height: 35.0,
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: _onRightChevronPressed,
            icon: Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
