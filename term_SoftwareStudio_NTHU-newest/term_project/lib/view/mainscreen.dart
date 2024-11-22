import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:term_project/services/providers/navbar_index_provider.dart';
import 'package:term_project/view/home.dart';
import 'package:term_project/view/profile.dart';
import 'package:term_project/view/list.dart';
import 'package:term_project/widgets/app_bar.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Unique key for the scaffold to force rebuild
  Key _scaffoldKey = UniqueKey();

  void _refreshPage() {
    setState(() {
      // Change the key to force the widget to rebuild
      _scaffoldKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: _MainScreenContent(refreshCallback: _refreshPage),
      bottomNavigationBar: const MyAppBar(),
    );
  }
}

class _MainScreenContent extends StatelessWidget {
  final VoidCallback refreshCallback;

  const _MainScreenContent({required this.refreshCallback});

  @override
  Widget build(BuildContext context) {
    final bottomNavBarIndexProvider =
        Provider.of<BottomNavBarIndexProvider>(context);

    return IndexedStack(
      index: bottomNavBarIndexProvider.selectedIndex,
      children: [
        Home(),
        ListScreen(),
        ProfileScreen(refreshCallback: refreshCallback),
      ],
    );
  }
}
