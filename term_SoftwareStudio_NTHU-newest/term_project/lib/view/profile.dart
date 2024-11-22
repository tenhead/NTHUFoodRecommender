import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:term_project/models/my_user.dart';
import 'package:term_project/widgets/my_drawer.dart';
import 'package:provider/provider.dart';
import 'package:term_project/services/providers/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback refreshCallback;

  const ProfileScreen({Key? key, required this.refreshCallback}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  User? user = FirebaseAuth.instance.currentUser;
  MyUser? myUser;
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  TextEditingController _weightController = TextEditingController();
  TextEditingController _heightController = TextEditingController();

  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;
  late AnimationController _controller4;
  late AnimationController _controller5;

  late Animation<double> _animation1;
  late Animation<double> _animation2;
  late Animation<double> _animation3;
  late Animation<double> _animation4;
  late Animation<double> _animation5;

  late Animation<double> _opacityAnimation1;
  late Animation<double> _opacityAnimation2;
  late Animation<double> _opacityAnimation3;
  late Animation<double> _opacityAnimation4;
  late Animation<double> _opacityAnimation5;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();

    if (user != null) {
      _fetchUserData();
    }
  }

  void _initializeAnimations() {
    _controller1 = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _controller2 = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _controller3 = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _controller4 = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _controller5 = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _animation1 = Tween<double>(begin: 15.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller1,
        curve: Curves.easeOut,
      ),
    );
    _animation2 = Tween<double>(begin: 15.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller2,
        curve: Curves.easeOut,
      ),
    );
    _animation3 = Tween<double>(begin: 15.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller3,
        curve: Curves.easeOut,
      ),
    );
    _animation4 = Tween<double>(begin: 15.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller4,
        curve: Curves.easeOut,
      ),
    );
    _animation5 = Tween<double>(begin: 15.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller5,
        curve: Curves.easeOut,
      ),
    );

    _opacityAnimation1 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller1,
        curve: Curves.easeOut,
      ),
    );
    _opacityAnimation2 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller2,
        curve: Curves.easeOut,
      ),
    );
    _opacityAnimation3 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller3,
        curve: Curves.easeOut,
      ),
    );
    _opacityAnimation4 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller4,
        curve: Curves.easeOut,
      ),
    );
    _opacityAnimation5 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller5,
        curve: Curves.easeOut,
      ),
    );

    // Start the animations
    _controller1.forward();
    _controller2.forward();
    _controller3.forward();
    _controller4.forward();
    _controller5.forward();
  }

  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (snapshot.exists) {
        setState(() {
          myUser = MyUser.fromMap(snapshot.data()!);
          _usernameController.text = myUser!.username;
          _ageController.text = myUser!.age?.toString() ?? '';
          _weightController.text = myUser!.weight?.toString() ?? '';
          _heightController.text = myUser!.height?.toString() ?? '';
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void _editProfile() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                TextField(
                  controller: _ageController,
                  decoration: const InputDecoration(labelText: 'Age'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _heightController,
                  decoration: const InputDecoration(labelText: 'Height (cm)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _weightController,
                  decoration: const InputDecoration(labelText: 'Weight (kg)'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _updateProfile();
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _updateProfile() async {
    try {
      // Update local MyUser object with new data
      myUser = MyUser(
        id: myUser!.id,
        username: _usernameController.text,
        email: myUser!.email,
        age: int.tryParse(_ageController.text),
        weight: double.tryParse(_weightController.text),
        height: double.tryParse(_heightController.text),
      );

      // Update Firestore document with new data
      await FirebaseFirestore.instance
          .collection('users')
          .doc(myUser!.id)
          .update(myUser!.toMap());

      setState(() {
        // Update local state with new user data
        _usernameController.text = myUser!.username;
        _ageController.text = myUser!.age?.toString() ?? '';
        _weightController.text = myUser!.weight?.toString() ?? '';
        _heightController.text = myUser!.height?.toString() ?? '';
      });

      // Refresh the MainScreen
      widget.refreshCallback();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    }
  }

  AnimationController _getController(int index) {
    switch (index) {
      case 0:
        return _controller1;
      case 1:
        return _controller2;
      case 2:
        return _controller3;
      case 3:
        return _controller4;
      case 4:
      default:
        return _controller5;
    }
  }

  Animation<double> _getOpacityAnimation(int index) {
    switch (index) {
      case 0:
        return _opacityAnimation1;
      case 1:
        return _opacityAnimation2;
      case 2:
        return _opacityAnimation3;
      case 3:
        return _opacityAnimation4;
      case 4:
      default:
        return _opacityAnimation5;
    }
  }

  Animation<double> _getAnimation(int index) {
    switch (index) {
      case 0:
        return _animation1;
      case 1:
        return _animation2;
      case 2:
        return _animation3;
      case 3:
        return _animation4;
      case 4:
      default:
        return _animation5;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          drawer: const MyDrawer(),
          appBar: AppBar(
            title: const Text('Profile'),
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  widget.refreshCallback();
                  _fetchUserData(); // Fetch user data and reset animations
                },
              ),
            ],
          ),
          extendBodyBehindAppBar: true,
          body: Stack(
            children: [
              // Background image container
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      themeProvider.isDarkTheme
                          ? 'assets/dark2.png'
                          : 'assets/background.jpg',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.only(
                  top: kToolbarHeight + 45.0,
                  left: 16.0,
                  right: 16.0,
                  bottom: 16.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(
                      child: AnimatedBuilder(
                        animation: _controller1,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _opacityAnimation1,
                            child: Transform.translate(
                              offset: Offset(0, _animation1.value),
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: themeProvider.isDarkTheme
                                        ? [Colors.deepPurple, Colors.deepPurpleAccent]
                                        : [Colors.green, Colors.lightGreen],
                                  ),
                                ),
                                child: Container(
                                  width: 120.0,
                                  height: 120.0,
                                  decoration: const BoxDecoration(
                                    color: Colors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    AnimatedBuilder(
                      animation: _controller2,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _opacityAnimation2,
                          child: Transform.translate(
                            offset: Offset(0, _animation2.value),
                            child: _buildProfileItem('Username:', _usernameController.text, themeProvider),
                          ),
                        );
                      },
                    ),
                    AnimatedBuilder(
                      animation: _controller3,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _opacityAnimation3,
                          child: Transform.translate(
                            offset: Offset(0, _animation3.value),
                            child: _buildProfileItem('Email:', myUser?.email ?? 'N/A', themeProvider),
                          ),
                        );
                      },
                    ),
                    AnimatedBuilder(
                      animation: _controller4,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _opacityAnimation4,
                          child: Transform.translate(
                            offset: Offset(0, _animation4.value),
                            child: _buildProfileItem('Age:', _ageController.text, themeProvider),
                          ),
                        );
                      },
                    ),
                    AnimatedBuilder(
                      animation: _controller5,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _opacityAnimation5,
                          child: Transform.translate(
                            offset: Offset(0, _animation5.value),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildProfileItem('Height:', '${_heightController.text} cm', themeProvider),
                                _buildProfileItem('Weight:', '${_weightController.text} kg', themeProvider),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
              Positioned(
                bottom: 18,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: _editProfile,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: themeProvider.isDarkTheme
                              ? [Colors.deepPurple, Colors.deepPurpleAccent]
                              : [Colors.green, Colors.lightGreen],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Text(
                        'Edit Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileItem(String label, String value, ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: themeProvider.isDarkTheme ? Colors.black54 : Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                color: themeProvider.isDarkTheme ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
