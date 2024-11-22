import 'package:flutter/material.dart';
import 'package:term_project/services/providers/navbar_index_provider.dart';
import 'services/routes.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:term_project/services/providers/image_provider.dart';
import 'package:term_project/updater/profile_provider.dart';
import 'package:term_project/services/providers/refresh_provider.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:term_project/services/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Gemini.init(
      apiKey: const String.fromEnvironment('AIzaSyBn4XmRa5Y7itICG5y557PUpZf21CRDvQc'), enableDebugging: true);

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => ImagesProvider()),
    ChangeNotifierProvider(create: (_) => BottomNavBarIndexProvider()),
    ChangeNotifierProvider(create: (_) => ProfileProvider()),
    ChangeNotifierProvider(create: (_) => RefreshProvider()),
    ChangeNotifierProvider(create: (_) => ThemeProvider()),  
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
  return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          darkTheme: ThemeData.dark(),  // Define your dark theme
          themeMode: themeProvider.themeMode,  // Set theme mode based on provider
          routerConfig: router,
    );
      },
  );
  }
}
