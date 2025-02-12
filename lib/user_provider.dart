import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserProvider with ChangeNotifier {
  String? _nickname;
  String? _email;
  String? _name;
  String? _birthDate;

  String? get nickname => _nickname;
  String? get email => _email;
  String? get name => _name;
  String? get birthDate => _birthDate;

  void setUserData(Map<String, dynamic> userData) {
    _nickname = userData['nickname'];
    _email = userData['email'];
    _name = userData['name'];
    _birthDate = userData['birth_date'];

    notifyListeners(); // 상태 변경 알림
  }

  void clearUserData() {
    _nickname = null;
    _email = null;
    _name = null;
    _birthDate = null;

    notifyListeners();
  }
}
