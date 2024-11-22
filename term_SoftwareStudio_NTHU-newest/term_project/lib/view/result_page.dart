import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:term_project/services/providers/image_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:term_project/services/providers/navbar_index_provider.dart';

class DisplayPhotoPage extends StatelessWidget {
  const DisplayPhotoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final photoUrl = Provider.of<ImagesProvider>(context).imageUrl;

    return WillPopScope(
      onWillPop: () async {
        // Update the BottomNavBarIndexProvider before navigating back
        Provider.of<BottomNavBarIndexProvider>(context, listen: false).setIndex(1);
        // Navigate back to the list screen
        context.go('/main');
        return false; // Prevent the default back button behavior
      },
      child:Scaffold(
      appBar: AppBar(title: const Text('Uploaded Photo')),
      body: Center(
        child: photoUrl == null
            ? const Text('No image URL')
            : Image.network(photoUrl),
      ),
      ),
    );
  }
}
