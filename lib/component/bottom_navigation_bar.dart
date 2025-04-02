import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ohmo/screen/daylog_screen.dart';
import 'package:ohmo/screen/home_screen.dart';
import 'package:ohmo/screen/my_screen.dart';

class OhmoBottomNavigationBar extends StatefulWidget{
  final int selectedIndex;
  final Function(int) onTabChange;

  OhmoBottomNavigationBar({
    required this.selectedIndex,
    required this.onTabChange,
});

  @override
  _OhmoBottomNavigationBarState createState()=>_OhmoBottomNavigationBarState();
}

class _OhmoBottomNavigationBarState extends State<OhmoBottomNavigationBar>{
  @override
  Widget build(BuildContext){
    return BottomNavigationBar(
        currentIndex:widget.selectedIndex,
        onTap: widget.onTabChange,
      items: [
        BottomNavigationBarItem(
          icon:
          widget.selectedIndex == 0
              ? SvgPicture.asset(
            'android/assets/images/calendar_selected.svg',
          )
              : SvgPicture.asset(
            'android/assets/images/calendar_unselected.svg',
          ),
          label: 'Calendar',
        ),
        BottomNavigationBarItem(
          icon:
          widget.selectedIndex == 1
              ? SvgPicture.asset(
            'android/assets/images/daylog_selected.svg',
          )
              : SvgPicture.asset(
            'android/assets/images/daylog_unselected.svg',
          ),
          label: 'Daylog',
        ),
        BottomNavigationBarItem(
          icon:
          widget.selectedIndex == 2
              ? SvgPicture.asset('android/assets/images/my_selected.svg')
              : SvgPicture.asset(
            'android/assets/images/my_unselected.svg',
          ),
          label: 'My',
        ),
      ],
      backgroundColor: Colors.white,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black,
      selectedLabelStyle: TextStyle(fontSize: 12,fontFamily: 'RubikSprayPaint'),
      unselectedLabelStyle: TextStyle(fontSize: 12,fontFamily: 'RubikSprayPaint'),
    );
  }
}