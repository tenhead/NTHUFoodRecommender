import 'package:flutter/material.dart';

class ProfileProvider with ChangeNotifier {
  String _username = 'XxNoobMaster69xX';
  int _age = 69;
  double _height = 169.0;
  double _weight = 169.0;

  String get username => _username;
  int get age => _age;
  double get height => _height;
  double get weight => _weight;

  void updateProfile(
      {required String username,
      required int age,
      required double height,
      required double weight}) {
    _username = username;
    _age = age;
    _height = height;
    _weight = weight;
    notifyListeners();
  }

  Future<void> loadProfileData() async {
    // Load data from SharedPreferences or any other storage
    // This is just a placeholder for loading logic
  }

  Future<void> saveProfileData() async {
    // Save data to SharedPreferences or any other storage
    // This is just a placeholder for saving logic
  }
}
