import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:term_project/models/my_record.dart';
import 'package:term_project/services/firestore_service.dart';
import 'package:term_project/services/image_analysis_service.dart';
import 'package:term_project/services/providers/image_provider.dart';
import 'package:intl/intl.dart';

class ItemDetailScreen extends StatelessWidget {
  final String itemId;


  const ItemDetailScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        context.go('/main');
        return false; // Prevent the default back button behavior
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Item Details'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              context.go('/main');
            },
          ),
        ),
        body: Builder(
          builder: (context) {
            final saveFuture = FirebaseService.instance.getRecordById(int.parse(itemId));

            return SingleChildScrollView(
              child: FutureBuilder<MyRecord?>(
                future: saveFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    final record = snapshot.data!;
                    return Column(
                      children: [
                        if (record.foodImage.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('No image URL'),
                          )
                        else
                          SizedBox(
                            width: double.infinity,
                            height: 300.0,
                            child: Image.network(
                              record.foodImage,
                              fit: BoxFit.cover,
                              loadingBuilder: (BuildContext context, Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                } else {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes !=
                                              null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        Container(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          width: double.infinity,
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                record.foodName,
                                style: const TextStyle(color: Colors.white, fontSize: 18),
                              ),
                              Text(
                                'Date added: ${record.dateTime}',
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          color: const Color.fromARGB(255, 20, 54, 21),
                          width: double.infinity,
                          padding: const EdgeInsets.all(16.0),
                          child: const Column(
                            children: [
                              Text(
                                'NUTRITIONAL FACTS',
                                style: TextStyle(color: Colors.white, fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.local_fire_department, color: Colors.white),
                          title: const Text('Calories', style: TextStyle(color: Colors.white)),
                          subtitle: Text(record.calories, style: const TextStyle(color: Colors.white)),
                          tileColor: const Color.fromARGB(255, 49, 98, 49),
                        ),
                        ListTile(
                          leading: const Icon(Icons.fastfood, color: Colors.white),
                          title: const Text('Carbohydrates', style: TextStyle(color: Colors.white)),
                          subtitle: Text(record.carbs, style: const TextStyle(color: Colors.white)),
                          tileColor: const Color.fromARGB(255, 32, 137, 29),
                        ),
                        ListTile(
                          leading: const Icon(Icons.fitness_center, color: Colors.white),
                          title: const Text('Protein', style: TextStyle(color: Colors.white)),
                          subtitle: Text(record.protein, style: const TextStyle(color: Colors.white)),
                          tileColor: const Color.fromARGB(255, 14, 175, 22),
                        ),
                        ListTile(
                          leading: Icon(Icons.opacity, color: Colors.white),
                          title: Text('Fat', style: TextStyle(color: Colors.white)),
                          subtitle: Text(record.fat, style: TextStyle(color: Colors.white)),
                          tileColor: Color.fromARGB(255, 90, 204, 58),
                        ),
                        ListTile(
                          leading: Icon(Icons.scale, color: Colors.white),
                          title: Text('Weight', style: TextStyle(color: Colors.white)),
                          subtitle: Text(record.weight, style: TextStyle(color: Colors.white)),
                          tileColor: Color.fromARGB(255, 86, 188, 81),
                        ),
                      ],
                    );
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
