import 'package:flutter/material.dart';

class GroupAddMemberScreen extends StatefulWidget {
  const GroupAddMemberScreen({Key? key}) : super(key: key);

  @override
  _GroupAddMemberScreenState createState() => _GroupAddMemberScreenState();
}

class _GroupAddMemberScreenState extends State<GroupAddMemberScreen> {
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
