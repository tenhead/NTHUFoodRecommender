import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:term_project/models/my_record.dart';
import 'package:term_project/services/providers/navbar_index_provider.dart';


class PhotoDisplayPage extends StatelessWidget {
  final String photoUrl;

  const PhotoDisplayPage({super.key, required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Update the BottomNavBarIndexProvider before navigating back
        Provider.of<BottomNavBarIndexProvider>(context).setIndex(1);
        // Navigate back to the list screen
        context.go('/main');
        return false; // Prevent the default back button behavior
      },
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Uploaded Photo'),
      ),
      body: Center(
        child: photoUrl.isNotEmpty
            ? Image.network(photoUrl)
            : const Text('No photo available'),
      ),
    )
    );
  }
}
