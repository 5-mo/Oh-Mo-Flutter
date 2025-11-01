import 'package:flutter/material.dart';

class GroupFinalEnterRoomScreen extends StatefulWidget {
  const GroupFinalEnterRoomScreen({Key? key}) : super(key: key);

  @override
  _GroupFinalEnterRoomScreenState createState() => _GroupFinalEnterRoomScreenState();
}

class _GroupFinalEnterRoomScreenState extends State<GroupFinalEnterRoomScreen> {


  @override
  void initState() {
    super.initState();

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
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 60.0),

            SizedBox(height: 30.0),

          ],
        ),
      ),
    );
  }




  Widget _buildNextButton() {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GroupFinalEnterRoomScreen()),
          );
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
              '다음',
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
}
