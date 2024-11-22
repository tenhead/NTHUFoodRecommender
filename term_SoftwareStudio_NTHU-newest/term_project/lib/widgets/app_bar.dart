import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:term_project/services/providers/navbar_index_provider.dart';
import 'package:term_project/services/providers/theme_provider.dart';

class MyAppBar extends StatelessWidget {
  const MyAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomNavBarIndexProvider =
        Provider.of<BottomNavBarIndexProvider>(context);

    void onItemTapped(int index) {
      bottomNavBarIndexProvider.setIndex(index);
            //Navigator.pop(context);
    }

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return CurvedNavigationBar(
          index: bottomNavBarIndexProvider.selectedIndex,
          items: const <Widget>[
            Icon(Icons.home, size: 30, color: Colors.white),
            Icon(Icons.book, size: 30, color: Colors.white),
            Icon(Icons.person, size: 30, color: Colors.white),
          ],
          onTap: onItemTapped,
          backgroundColor: Colors.transparent,
          color: themeProvider.isDarkTheme
              ? Color.fromARGB(255, 91, 51, 166)
              : Color.fromARGB(255, 86, 188, 81),
        );
      },
    );
  }
}