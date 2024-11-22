import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:term_project/models/my_user.dart';
import 'package:provider/provider.dart';
import 'package:term_project/services/providers/theme_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  String _message = '';

  // Variable to store the current user data
  MyUser? currentUser;

  Future<void> _register() async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      MyUser newUser = MyUser(
        id: userCredential.user!.uid,
        username: _usernameController.text,
        email: _emailController.text,
        age: int.tryParse(_ageController.text), // Nullable int
        weight: double.tryParse(_weightController.text), // Nullable double
        height: double.tryParse(_heightController.text), // Nullable double
      );

      await _firestore.collection('users').doc(newUser.id).set(newUser.toMap());

      // Update the current user data
      setState(() {
        currentUser = newUser;
        _message = 'Successfully registered: ${newUser.email}';
      });

      // Debug print statement to verify the data
      print('New user data: ${currentUser?.toMap()}');

      // Navigate back to the login page
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _message = 'Failed to register, $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Define colors based on theme
    Color buttonColor = themeProvider.isDarkTheme ? Colors.deepPurple : Colors.green;
    Color alreadyHaveAccountColor = themeProvider.isDarkTheme ? Colors.white : Colors.purple;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              themeProvider.isDarkTheme
                  ? "assets/dark_background.jpg"
                  : "assets/background.jpg",
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Text(
                  'Create an Account',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkTheme ? Color.fromARGB(255, 235, 137, 10) : Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Welcome! Please enter your details.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 20),
                buildTextField(_usernameController, 'Username'),
                SizedBox(height: 20),
                buildTextField(_emailController, 'Email'),
                SizedBox(height: 20),
                buildTextField(_passwordController, 'Password', isPassword: true),
                SizedBox(height: 20),
                buildTextField(_ageController, 'Age', keyboardType: TextInputType.number),
                SizedBox(height: 20),
                buildTextField(_weightController, 'Weight', keyboardType: TextInputType.number),
                SizedBox(height: 20),
                buildTextField(_heightController, 'Height', keyboardType: TextInputType.number),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _register,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(buttonColor),
                    ),
                    child: Text(
                      'Register',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  _message,
                  style: TextStyle(
                    color: themeProvider.isDarkTheme ? Colors.redAccent : Colors.red,
                  ),
                ),
                SizedBox(height: 10),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Navigate back to login page
                    },
                    child: Text.rich(
                      TextSpan(
                        text: 'Already have an account? ',
                        style: TextStyle(
                          color: alreadyHaveAccountColor,
                          fontSize: 16,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Login here',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 16,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label,
      {bool isPassword = false, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      ),
    );
  }
}
