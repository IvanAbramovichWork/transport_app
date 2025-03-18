import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _isLoggedIn = true;
      String userId = email;
      Map<String, dynamic>? userData = await getUserData(userId);
      if (userData?['userType'] == "client") {
        _userType = UserType.client;
      } else if (userData?['userType'] == "employee") {
        _userType = UserType.employee;
      }
      else {
        throw("unknown user type");
      }
      _email = email;
      _userId = userData?['id'];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('isLoggedIn', _isLoggedIn);
      prefs.setString('userEmail', _email!);
      prefs.setString('userType', _userType.toString());
      prefs.setInt('userId', _userId!); // Сохраняем userId
      notifyListeners();
      print('User signed in: ${userCredential.user!.uid}');
    } catch (e) {
      print('Error: $e');
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
Future<Map<String, dynamic>?> getUserData(String userId) async {
  try {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (userDoc.exists) {
      return userDoc.data() as Map<String, dynamic>;
    } else {
      return null;
    }
  } catch (e) {
    print('Error: $e');
    return null;
  }
}