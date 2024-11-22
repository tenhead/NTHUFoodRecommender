import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:term_project/models/my_user.dart';
import 'package:provider/provider.dart';
import 'package:term_project/services/providers/theme_provider.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _message = '';

  void _login() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Clear any previous error message upon successful login
      setState(() {
        _message = '';
      });

      // Navigate to '/main' route upon successful login
      context.go('/main');
    } catch (e) {
      // Handle login failures
      setState(() {
        _message = 'Email or password is wrong!';
      });
    }
  }

  Future<void> _loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      MyUser newUser = MyUser(
        id: userCredential.user!.uid,
        username: googleUser.displayName ?? '',
        email: googleUser.email,
      );
      await _firestore.collection('users').doc(newUser.id).set(newUser.toMap());

      setState(() {
        context.go('/main');
      });
    } catch (e) {
      setState(() {
        _message = 'Failed to log in with Google';
      });
    }
  }

  void _navigateToRegisterPage(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => RegisterPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Determine border color based on error message presence
    Color emailBorderColor = _message.isNotEmpty ? Colors.red : Colors.grey;
    Color passwordBorderColor = _message.isNotEmpty ? Colors.red : Colors.grey;

    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevents wallpaper from moving
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: kToolbarHeight), // To push content below the app bar
                const Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  onChanged: (_) {
                    // Clear error message when user starts typing in email field
                    if (_message.isNotEmpty) {
                      setState(() {
                        _message = '';
                      });
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(color: emailBorderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(color: emailBorderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  onChanged: (_) {
                    // Clear error message when user starts typing in password field
                    if (_message.isNotEmpty) {
                      setState(() {
                        _message = '';
                      });
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(color: passwordBorderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(color: passwordBorderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                if (_message.isNotEmpty)
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      _message,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: _login,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: themeProvider.isDarkTheme
                              ? [Colors.deepPurple, Colors.deepPurpleAccent]
                              : [Colors.green, Colors.lightGreen],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: const Center(
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'or continue with',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 10),
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: Image.asset('assets/google_logo.png'),
                    onPressed: _loginWithGoogle,
                    tooltip: 'Login with Google',
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => _navigateToRegisterPage(context),
                  child: RichText(
                    text: TextSpan(
                      text: 'New User? ',
                      style: TextStyle(
                        color: themeProvider.isDarkTheme
                            ? Colors.white
                            : Colors.black,
                      ),
                      children: const <TextSpan>[
                        TextSpan(
                          text: 'Register Now',
                          style: TextStyle(
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
