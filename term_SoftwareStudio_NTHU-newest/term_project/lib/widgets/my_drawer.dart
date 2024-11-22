import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:term_project/models/my_user.dart';
import 'package:term_project/services/providers/navbar_index_provider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:term_project/services/providers/theme_provider.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  Future<MyUser?> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot<Map<String, dynamic>> snapshot =
            await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        if (snapshot.exists) {
          return MyUser.fromMap(snapshot.data()!);
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bottomNavBarIndexProvider =
        Provider.of<BottomNavBarIndexProvider>(context);
    User? user = FirebaseAuth.instance.currentUser;

    void onItemTapped(int index) async {
      if (index == 3) { // Logout
        await FirebaseAuth.instance.signOut();
        Navigator.pop(context); // Close the drawer
        context.read<BottomNavBarIndexProvider>().setIndex(0); // Reset bottom nav index
        context.go('/'); // Navigate to login screen
      } else {
        bottomNavBarIndexProvider.setIndex(index);
        Navigator.pop(context); // Close the drawer
        if (index == 0) {
          context.go('/main');
        } else if (index == 1) {
          context.go('/main');
        } else if (index == 2) {
          context.go('/main');
        }
      }
    }

    return Drawer(
      child: FutureBuilder<MyUser?>(
        future: _fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error fetching user data'));
          } else {
            MyUser? myUser = snapshot.data;
            return Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return ListView(
                  children: [
                    Stack(
                      children: [
                        UserAccountsDrawerHeader(
                          decoration: BoxDecoration(
                            color: themeProvider.isDarkTheme
                                ? const Color.fromARGB(255, 44, 10, 106).withOpacity(1)
                                : const Color.fromARGB(232, 2, 95, 64),
                          ),
                          accountName: Text(myUser?.username ?? ''),
                          accountEmail: Text(user?.email ?? ''),
                          currentAccountPicture: const CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: ThemeToggleButton(),
                        ),
                      ],
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: 4,
                      itemBuilder: (BuildContext context, int index) {
                        if (index == 3) {
                          return Column(
                            children: [
                              const Row(
                                children: [
                                  Expanded(
                                    flex: 6,
                                    child: Divider(),
                                  ),
                                  Spacer(flex: 1),
                                ],
                              ),
                              ListTile(
                                title: const Text(
                                  'Logout',
                                  style: TextStyle(color: Colors.red),
                                ),
                                onTap: () => onItemTapped(index),
                              ),
                            ],
                          );
                        }

                        String title = '';
                        switch (index) {
                          case 0:
                            title = 'Home';
                            break;
                          case 1:
                            title = 'List';
                            break;
                          case 2:
                            title = 'Profile';
                            break;
                        }
                        return ListTile(
                          title: Text(title),
                          onTap: () => onItemTapped(index),
                        );
                      },
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }
}

class ThemeToggleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return IconButton(
          icon: Icon(themeProvider.isDarkTheme ? Icons.dark_mode : Icons.light_mode),
          onPressed: () {
            themeProvider.toggleTheme();
          },
        );
      },
    );
  }
}
