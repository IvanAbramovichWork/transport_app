import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/database_helper.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String? _email;
  int? _userId;
  UserType _userType = UserType.client;

  bool get isLoggedIn => _isLoggedIn;
  String? get email => _email;
  int? get userId => _userId;
  UserType get userType => _userType;

  bool get isEmployee => _userType == UserType.employee;

  // Метод для входа
  Future<void> login(String email, String password) async {
    final dbHelper = DatabaseHelper.instance;
    final user = await dbHelper.getUserByEmail(email);

    if (user != null && user.password == password) {
      _isLoggedIn = true;
      _email = user.email;
      _userId = user.id;
      _userType = user.userType;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('isLoggedIn', _isLoggedIn);
      prefs.setString('userEmail', _email!);
      prefs.setString('userType', _userType.toString());
      prefs.setInt('userId', _userId!); // Сохраняем userId
      notifyListeners();
    } else {
      throw Exception('Неверный email или пароль');
    }
  }

  // Метод для выхода
  Future<void> logout() async {
    _isLoggedIn = false;
    _email = null;
    _userId = null;
    _userType = UserType.client;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('isLoggedIn');
    prefs.remove('userEmail');
    prefs.remove('userType');
    prefs.remove('userId'); // Удаляем userId
    notifyListeners();
  }

  // Проверка статуса входа
  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _email = prefs.getString('userEmail');
    _userId = prefs.getInt('userId'); // Загружаем userId
    String? userTypeString = prefs.getString('userType');
    if (userTypeString != null) {
      _userType = userTypeString == 'UserType.employee' ? UserType.employee : UserType.client;
    }
    notifyListeners();
  }
}