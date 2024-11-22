import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:term_project/services/providers/navbar_index_provider.dart';
import 'package:term_project/models/my_record.dart';
import 'package:term_project/services/firestore_service.dart';
import 'package:term_project/services/providers/image_provider.dart';
import 'package:term_project/services/camera_service.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecentPhoto extends StatefulWidget {
  final Function(int, double, double, double) onCaloriesChanged;

  const RecentPhoto({super.key, required this.onCaloriesChanged});

  @override
  _RecentPhotoState createState() => _RecentPhotoState();
}

class _RecentPhotoState extends State<RecentPhoto> {
  List<MyRecord> _foodItems = [];
  List<MyRecord> _allDailyRecords = [];
  final CameraService _cameraService = CameraService();
  bool _hasMoreThanFourItems = false;

  @override
  void initState() {
    super.initState();
    _loadRecentFoodItems();
  }

  Future<void> _loadRecentFoodItems() async {
    User? user = FirebaseAuth.instance.currentUser;
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('users')
        .doc(user!.uid)
        .get();

    String username = snapshot.data()?['username'] ?? 'Unknown';

    List<MyRecord> allRecords = await FirebaseService.instance.loadAllRecords();
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    _allDailyRecords = allRecords
        .where((record) => record.dateTime == today && record.username == username)
        .toList();

    _allDailyRecords.sort((a, b) => b.id.compareTo(a.id));
    print('Total daily records: ${_allDailyRecords.length}');

    _hasMoreThanFourItems = _allDailyRecords.length > 4;

    if (_allDailyRecords.length > 4) {
      _foodItems = _allDailyRecords.take(4).toList();
    } else {
      _foodItems = _allDailyRecords;
    }

    _updateNutrition();
    setState(() {
      print('Loaded ${_foodItems.length} items. More than 4 items: $_hasMoreThanFourItems');
    });
  }

  void _updateNutrition() {
    int totalCalories = _allDailyRecords.fold<int>(0, (sum, item) => sum + _parseInt(item.calories));
    double totalProtein = _allDailyRecords.fold<double>(0.0, (sum, item) => sum + _parseDouble(item.protein));
    double totalFat = _allDailyRecords.fold<double>(0.0, (sum, item) => sum + _parseDouble(item.fat));
    double totalCarbs = _allDailyRecords.fold<double>(0.0, (sum, item) => sum + _parseDouble(item.carbs));

    widget.onCaloriesChanged(totalCalories, totalProtein, totalFat, totalCarbs);
  }

  int _parseInt(String input) {
    try {
      return int.parse(input.replaceAll(RegExp(r'[^0-9]'), ''));
    } catch (e) {
      return 0;
    }
  }

  double _parseDouble(String input) {
    try {
      return double.parse(input.replaceAll(RegExp(r'[^0-9.]'), ''));
    } catch (e) {
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _foodItems.isEmpty
            ? Center(
                child: Column(
                  children: [
                    const Text('Go take a photo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        MyRecord? newRecord = await _cameraService.takePicture(context);
                        if (newRecord != null && mounted) {
                          setState(() {
                            _loadRecentFoodItems();
                          });
                          Provider.of<ImagesProvider>(context, listen: false).setImageUrl(newRecord.foodImage);
                        } else if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to take or upload picture')),
                          );
                        }
                      },
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Take Photo'),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _foodItems.length,
                itemBuilder: (context, index) {
                  final foodItem = _foodItems[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () => context.go('/main/list/${foodItem.id}'),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 5,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      foodItem.foodName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${foodItem.calories} CAL',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 50),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  height: 125,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      image: foodItem.foodImage.isNotEmpty
                                          ? NetworkImage(foodItem.foodImage)
                                          : AssetImage('assets/placeholder_image.jpg') as ImageProvider,
                                      fit: BoxFit.cover,
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
                },
              ),
        if (_hasMoreThanFourItems)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  // Update the BottomNavBarIndexProvider before navigating
                  Provider.of<BottomNavBarIndexProvider>(context, listen: false).setIndex(1);
                  context.go('/main');
                },
                child: const Text('See All'),
              ),
            ),
          ),
      ],
    );
  }
}
