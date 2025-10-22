import 'package:flutter/material.dart';

class GroupEnterRoomScreen extends StatefulWidget {
  const GroupEnterRoomScreen({Key? key}) : super(key: key);

  @override
  _GroupEnterRoomScreenState createState() => _GroupEnterRoomScreenState();
}

class _GroupEnterRoomScreenState extends State<GroupEnterRoomScreen> {
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
