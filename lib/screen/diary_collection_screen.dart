import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../db/drift_database.dart' as db;
import 'package:intl/intl.dart';

import 'daylog_screen.dart';

class DiaryCollectionScreen extends StatefulWidget {
  final ValueNotifier<DateTime> selectedDateNotifier;
  final Function(int) onTabChange;

  DiaryCollectionScreen({
    required this.selectedDateNotifier,
    required this.onTabChange,});

  @override
  State<DiaryCollectionScreen> createState() => _DiaryCollectionScreenState();
}

class _DiaryCollectionScreenState extends State<DiaryCollectionScreen> {
  late DateTime _focusedDay;
  db.Emotion _currentEmotion = db.Emotion.none;
  String _diaryText = '';
  final db.LocalDatabase _database = db.LocalDatabaseSingleton.instance;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.selectedDateNotifier.value;
    _loadDiaryForDay(_focusedDay);
  }

  Future<void> _loadDiaryForDay(DateTime date) async {
    final dayLog = await _database.getDayLog(date);
    if (!mounted) return;

    db.Emotion loadedEmotion = db.Emotion.none;
    String loadedDiary = '아직 작성된 일기가 없어요.\n오늘을 기록하러 가볼까요?';

    if (dayLog != null) {
      if (dayLog.emotion != null) {
        switch (dayLog.emotion) {
          case 'happy':
            loadedEmotion = db.Emotion.happy;
            break;
          case 'soso':
            loadedEmotion = db.Emotion.soso;
            break;
          case 'bad':
            loadedEmotion = db.Emotion.bad;
            break;
        }
      }

      if (dayLog.diary != null && dayLog.diary!.isNotEmpty) {
        loadedDiary = dayLog.diary!;
      }
    }

    setState(() {
      _currentEmotion = loadedEmotion;
      _diaryText = loadedDiary;
    });
  }

  Future<void> _updateFocusedDay(DateTime newDate) async {
    setState(() {
      _focusedDay = newDate;
      if (widget.selectedDateNotifier.value != newDate) {
        widget.selectedDateNotifier.value = newDate;
      }
    });
    await _loadDiaryForDay(newDate);
  }

  void _onLeftChevronPressed() {
    _updateFocusedDay(_focusedDay.subtract(Duration(days: 1)));
  }

  void _onRightChevronPressed() {
    _updateFocusedDay(_focusedDay.add(Duration(days: 1)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 50.0),
              _buildHeader(),
              SizedBox(height: 10.0),
              _buildEmotion(),
              _buildDiaryContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: _onLeftChevronPressed,
          ),
          SizedBox(width: 50.0),
          Text(
            DateFormat('yyyy. MM. dd').format(_focusedDay),
            style: TextStyle(fontSize: 16.0, fontFamily: 'PretendardRegular'),
          ),
          SizedBox(width: 50.0),
          IconButton(
            icon: Icon(Icons.chevron_right),
            onPressed: _onRightChevronPressed,
          ),
        ],
      ),
    );
  }

  Widget _buildEmotion() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'android/assets/images/happy_unselected.svg',
            color:
                _currentEmotion == db.Emotion.happy
                    ? Colors.black
                    : Colors.grey,
            height: 40.0,
          ),
          SizedBox(width: 5.0),
          SvgPicture.asset(
            'android/assets/images/soso_unselected.svg',
            color:
                _currentEmotion == db.Emotion.soso ? Colors.black : Colors.grey,
            height: 40.0,
          ),
          SizedBox(width: 5.0),
          SvgPicture.asset(
            'android/assets/images/bad_unselected.svg',
            color:
                _currentEmotion == db.Emotion.bad ? Colors.black : Colors.grey,
            height: 40.0,
          ),
        ],
      ),
    );
  }

  Widget _buildDiaryContent() {
    final bool isPlaceholder = _diaryText == '아직 작성된 일기가 없어요.\n오늘을 기록하러 가볼까요?';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 50.0),
      child: Container(
        width: double.infinity,
        height: 248,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 25.0),
        alignment: isPlaceholder ? Alignment.center : Alignment.topLeft,
        decoration: BoxDecoration(color: Colors.grey[100]),
        child: Column(
          mainAxisAlignment:
          isPlaceholder ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Text(
              _diaryText,
              textAlign: isPlaceholder ? TextAlign.center : TextAlign.start,
              style: TextStyle(
                fontSize: isPlaceholder ? 10.0 : 13.0,
                fontFamily:
                    isPlaceholder ? 'PretendardSemiBold' : 'PretendardRegular',
                height: isPlaceholder ? 1.3 : 1.8,
                color: isPlaceholder ? Colors.grey[600] : Colors.black,
              ),
            ),
            if (isPlaceholder) ...[SizedBox(height: 20.0), _buildDiaryButton()],
          ],
        ),
      ),
    );
  }

  Widget _buildDiaryButton() {
    return GestureDetector(
      onTap: (){
         Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => DaylogScreen(
                  selectedDate: _focusedDay,
                  selectedDateNotifier: widget.selectedDateNotifier,
                  onTabChange: (index) {},
                  routines: [],
                  todos: [],
                ),
          ),
        );
        _loadDiaryForDay(_focusedDay);
      },
      child: Container(
        width: 87,
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
          child: Text(
            '일기쓰러 가기',
            style: TextStyle(fontSize: 10, fontFamily: 'PretendardRegular'),
          ),
        ),
      ),
    );
  }
}
