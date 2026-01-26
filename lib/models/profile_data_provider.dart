import 'dart:io';
import 'package:flutter/material.dart';

class ProfileData extends ChangeNotifier {
  File? image;
  String? imageUrl;
  String nickname = '오모';
  String email = 'user@ohmo.com';

  void updateProfile({
    File? updateImage,
    String? updateNickname,
    String? updateEmail,
  }) {
    if (updateImage != null) image = updateImage;
    if (updateNickname != null) nickname = updateNickname;
    if (updateEmail != null) email = updateEmail;
    notifyListeners();
  }

  void updateFromApi(Map<String, dynamic> apiData) {
    final data = apiData;

    if (data != null) {
      nickname = data['nickname'] ?? nickname;
      email = data['email'] ?? email;
      imageUrl = data['profileImageUrl'];
      notifyListeners();
    }
  }
}
