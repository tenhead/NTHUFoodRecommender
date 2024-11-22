import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:term_project/models/my_user.dart';
import 'package:term_project/widgets/my_drawer.dart';
import 'package:term_project/widgets/recent_photo.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:term_project/services/providers/theme_provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  User? user = FirebaseAuth.instance.currentUser;
  MyUser? myUser;
  double bmr = 0.0;
  double calories = 0.0;
  double protein = 0.0;
  double fat = 0.0;
  double carbs = 0.0;
  double bmi = 0.0;
  double prot_max = 0.0;
  double carb_max = 0.0;
  double fat_max = 0.0;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      _fetchUserData();
    }
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
          bmr = _calculateBMR(
              myUser!.age ?? 0, myUser!.height ?? 0.0, myUser!.weight ?? 0.0);
          bmi = _calculateBMI(myUser!.height ?? 0.0, myUser!.weight ?? 0.0);
          if (bmr > 0) {
            prot_max = _calculateProt(bmr);
            carb_max = _calculateCarb(bmr);
            fat_max = _calculateFat(bmr);
          }
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  double _calculateBMR(int age, double height, double weight) {
    // Harris-Benedict equation (generic formula, not gender-specific)
    if (age <= 0 || height <= 0 || weight <= 0) return 0.0;
    return 66 + (6.23 * weight) + (12.7 * height) - (6.8 * age);
  }

  double _calculateBMI(double height, double weight) {
    if (height <= 0 || weight <= 0) return 0.0;
    return weight / ((height / 100) * (height / 100));
  }

  double _calculateProt(double bmr) {
    return (bmr * 0.3) / 4;
  }

  double _calculateCarb(double bmr) {
    return (bmr * 0.4) / 4;
  }

  double _calculateFat(double bmr) {
    return (bmr * 0.3) / 9;
  }

  Widget _buildCircularProgressIndicator(double value, String label, double maxValue) {
    double progressValue = maxValue > 0 ? value / maxValue : 0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          height: 180, // Increased height
          width: 180, // Increased width
          child: Stack(
            children: [
              Center(
                child: Container(
                  height: 180, // Match the size of the SizedBox
                  width: 180, // Match the size of the SizedBox
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 4), // Outer black border
                    borderRadius: BorderRadius.circular(90), // Make it circular
                  ),
                  child: Center(
                    child: Container(
                      height: 172, // Slightly smaller to fit inside the outer border
                      width: 172, // Slightly smaller to fit inside the outer border
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 2), // Inner black border
                        borderRadius: BorderRadius.circular(86), // Make it circular
                      ),
                      child: CircularProgressIndicator(
                        value: progressValue.isFinite ? progressValue : 0,
                        strokeWidth: 12, // Increased stroke width for better visibility
                        backgroundColor: Colors.grey[300],
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      size: 40,
                    ),
                    Text(
                      '${calories.ceil()}',
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.orange),
                    ),
                    Text(
                      ' / ${bmr.ceil()}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'KCAL LEFT',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLinearProgressIndicator(double value, String label, double maxValue, Color color, {bool showValueLeft = true}) {
    double progressValue = maxValue > 0 ? value / maxValue : 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Container(
          height: 14,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.black, width: 1), // Black outline
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: progressValue.isFinite ? (progressValue > 1 ? 1 : progressValue) : 0,
              backgroundColor: Colors.transparent, // Make the background transparent to show the container's color
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        if (showValueLeft)
          Text(
            '${(maxValue - value).toStringAsFixed(1)}g left',
            style: const TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          )
        else
          Text(
            '${(progressValue * 100).toStringAsFixed(1)}%',
            style: const TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.chat),
            onPressed: () {
              context.go('/main/ai');
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _fetchUserData();
              });
            },
          ),
        ],
      ),
      drawer: const MyDrawer(),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      themeProvider.isDarkTheme 
                      ? 'assets/dark2.png' 
                      : 'assets/background.jpg'
                    ), 
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    // Green Background Box with Calories and Goals
                    ClipPath(
                      clipper: CurvedBottomClipper(),
                      child: Container(
                        height: 560,
                        color: themeProvider.isDarkTheme
                            ? const Color.fromARGB(255, 44, 10, 106)?.withOpacity(0.5)
                            : Colors.green[100]?.withOpacity(1), // Color based on theme
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            const SizedBox(height: 40),
                            Text(
                              'Hi, ${myUser?.username ?? 'User'}', // Display username if available
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            _buildCircularProgressIndicator(calories, 'Calories', bmr),
                            const SizedBox(height: 32),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 40.0),
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: _buildLinearProgressIndicator(protein, 'Protein', prot_max, Colors.purple),
                                      ),
                                      const SizedBox(width: 30),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            const SizedBox(height: 30), // Add space above the Fat bar
                                            _buildLinearProgressIndicator(fat, 'Fat', fat_max, Colors.blue),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 30),
                                      Expanded(
                                        child: _buildLinearProgressIndicator(carbs, 'Carbs', carb_max, Colors.green),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 30),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 150, // Set a specific width for the BMI progress bar
                                        child: _buildLinearProgressIndicator(bmi, 'BMI', 40, Colors.red, showValueLeft: false),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'Your recent food data',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          RecentPhoto(
                            onCaloriesChanged: (int totalCalories, double totalProtein, double totalFat, double totalCarbs) {
                              setState(() {
                                calories = totalCalories.toDouble();
                                protein = totalProtein;
                                fat = totalFat;
                                carbs = totalCarbs;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class CurvedBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 50);
    var firstControlPoint = Offset(size.width, size.height + 10);
    var firstEndPoint = Offset(size.width, size.height - 50);
    var secondControlPoint = Offset(size.width - 150, size.height + 10);
    var secondEndPoint = Offset(size.width, size.height - 50);

    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);
    path.lineTo(size.width, size.height - 50);
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
