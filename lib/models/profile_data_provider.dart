import 'dart:io';
import 'package:flutter/material.dart';

class ProfileData extends ChangeNotifier {
  File? image;
  String nickname = '오모';
  String email = 'user@ohmo.com';

  void updateProfile({File? updateImage, String? updateNickname, String? updateEmail}) {
    if (updateImage != null) image = updateImage;
    if (updateNickname != null) nickname = updateNickname;
    if (updateEmail != null) email = updateEmail;
    notifyListeners();
  }
}
