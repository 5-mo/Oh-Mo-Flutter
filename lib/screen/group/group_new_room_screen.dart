import 'package:flutter/material.dart';

class GroupNewRoomScreen extends StatefulWidget {
  const GroupNewRoomScreen({Key? key}) : super(key: key);

  @override
  _GroupNewRoomScreenState createState() => _GroupNewRoomScreenState();
}

class _GroupNewRoomScreenState extends State<GroupNewRoomScreen> {
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
            SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }

}
