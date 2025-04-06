import 'package:flutter/material.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
      ),

      body: Stack(
        children: [
          Positioned(
            top: 30,
            left: 35,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCategoryHeader(),
                SizedBox(height: 20.0),
                _buildRoutineIndex(),
                SizedBox(height: 10.0),
                _buildTodoIndex(),
                SizedBox(height: 10.0),
                _buildDaylogIndex(),
                SizedBox(height: 10.0),
                _buildDiaryIndex(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader() {
    return Text(
        '카테고리 관리',
        style: TextStyle(fontFamily: 'PretendardBold', fontSize: 18.0),
    );
  }

  Widget _buildRoutineIndex() {
    return Container(
      width: 330,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
        ],
      ),
      child: Center(
        child: Row(
          children: [
            SizedBox(width: 20.0),
            Text(
              'Routine',
              style: TextStyle(fontSize: 14, fontFamily: 'RubikSprayPaint'),
            ),
            SizedBox(width:200.0),
            IconButton(
              icon: Icon(Icons.add_circle),
              onPressed: () {
              },
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildTodoIndex() {
    return Container(
      width: 330,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
        ],
      ),
      child: Center(
        child: Row(
          children: [
            SizedBox(width: 20.0),
            Text(
              'Routine',
              style: TextStyle(fontSize: 14, fontFamily: 'RubikSprayPaint'),
            ),
            SizedBox(width:200.0),
            IconButton(
              icon: Icon(Icons.add_circle),
              onPressed: () {
              },
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaylogIndex() {
    return Container(
      width: 330,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
        ],
      ),
      child: Center(
        child: Row(
          children: [
            SizedBox(width: 20.0),
            Text(
              'Day log Question',
              style: TextStyle(fontSize: 14, fontFamily: 'RubikSprayPaint'),
            ),
            SizedBox(width:135.0),
            IconButton(
              icon: Icon(Icons.add_circle),
              onPressed: () {
              },
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiaryIndex() {
    return Container(
      width: 330,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
        ],
      ),
      child: Center(
        child: Row(
          children: [
            SizedBox(width: 20.0),
            Text(
              'Diary',
              style: TextStyle(fontSize: 14, fontFamily: 'RubikSprayPaint'),
            ),
          ],
        ),
      ),
    );
  }
}
