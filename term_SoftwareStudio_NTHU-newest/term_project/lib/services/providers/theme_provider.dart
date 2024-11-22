import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkTheme = false;

  bool get isDarkTheme => _isDarkTheme;

  ThemeMode get themeMode => _isDarkTheme ? ThemeMode.dark : ThemeMode.light;

  ThemeProvider() {
    _loadThemeFromFirebase();
  }

  Future<void> _loadThemeFromFirebase() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (snapshot.exists && snapshot.data() != null) {
        _isDarkTheme = snapshot.data()!['isDarkTheme'] ?? false;
        notifyListeners();
      }
    }
  }

  Future<void> _saveThemeToFirebase() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {'isDarkTheme': _isDarkTheme},
        SetOptions(merge: true),
      );
    }
  }

  void toggleTheme() {
    _isDarkTheme = !_isDarkTheme;
    _saveThemeToFirebase();
    notifyListeners();
  }
}
