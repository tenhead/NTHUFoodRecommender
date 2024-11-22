import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:term_project/models/my_record.dart';
import 'package:term_project/services/camera_service.dart';
import 'package:term_project/services/firestore_service.dart';
import 'package:term_project/services/providers/image_provider.dart';
import 'package:term_project/widgets/my_drawer.dart';
import 'package:provider/provider.dart';
import 'package:term_project/services/providers/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final CameraService _cameraService = CameraService();
  List<MyRecord> records = [];
  String _selectedTab = 'All'; // Track the selected tab
  String _currentUsername = ''; // Track the current user's username

  @override
  void initState() {
    super.initState();
    _fetchCurrentUsername();
    _loadRecords();
  }

  Future<void> _fetchCurrentUsername() async {
    User? user = FirebaseAuth.instance.currentUser;
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('users')
        .doc(user!.uid)
        .get();

    setState(() {
      _currentUsername = snapshot.data()?['username'] ?? 'Unknown';
    });
  }

  Future<void> _loadRecords() async {
    records = await FirebaseService.instance.loadAllRecords();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<MyRecord> filteredRecords = _selectedTab == 'All'
        ? records.where((record) => record.username == _currentUsername).toList()
        : records.where((record) => record.dateTime == DateFormat('yyyy-MM-dd').format(DateTime.now()) && record.username == _currentUsername).toList();

    // Sort records by dateTime in descending order
    filteredRecords.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: const MyDrawer(),
        appBar: AppBar(
          title: const Text('List'),
          actions: [
            IconButton(
              onPressed: () async {
                MyRecord? newRecord = await _cameraService.takePicture(context);
                if (newRecord != null && mounted) {
                  _loadRecords(); // Reload records to include the new one
                  if (mounted) {
                    Provider.of<ImagesProvider>(context, listen: false).setImageUrl(newRecord.foodImage);
                    context.go('/main/list/${newRecord.id}');
                  }
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to take or upload picture')),
                  );
                }
              },
              icon: Icon(Icons.camera_alt_outlined, size: 30),
            ),
          ],
          bottom: TabBar(
            onTap: (index) {
              setState(() {
                _selectedTab = index == 0 ? 'All' : 'Daily';
              });
            },
            tabs: [
              Tab(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.rectangle,
                  ),
                  child: Center(
                    child: Text(
                      'All',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
              Tab(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.rectangle,
                  ),
                  child: Center(
                    child: Text(
                      'Daily',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            Color shadowColor = themeProvider.isDarkTheme ? Colors.black54 : Colors.grey[400]!;

            return Stack(
              children: [
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
                Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredRecords.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Container(
                              height: 250,
                              width: double.infinity,
                              padding: EdgeInsets.all(20),
                              margin: EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                image: DecorationImage(
                                  image: filteredRecords[index].foodImage.isNotEmpty
                                      ? NetworkImage(filteredRecords[index].foodImage)
                                      : AssetImage('assets/placeholder_image.jpg') as ImageProvider, // Placeholder for empty image URLs
                                  fit: BoxFit.fill,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: shadowColor,
                                    blurRadius: 10,
                                    offset: Offset(0, 10),
                                  )
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                              color: Colors.black.withOpacity(0.5), // Semi-transparent black background
                                              child: Text(
                                                "${filteredRecords[index].foodName}",
                                                style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            SizedBox(height: 130),
                                            Container(
                                              color: Colors.black.withOpacity(0.5), // Semi-transparent black background
                                              child: Text(
                                                'Date: ${filteredRecords[index].dateTime}',
                                                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            onTap: () {
                              context.go('/main/list/${filteredRecords[index].id}');
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
