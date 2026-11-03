import 'dart:async';
import 'package:flutter/material.dart';
import 'mainscreen.dart';
import 'splashscreen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool showSplash = true;

  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 5), () {
      setState(() {
        showSplash = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StudyTrack',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        useMaterial3: true,
      ),
      home: showSplash
          ? const SplashScreen()
          : const MainScreen(),
    );
  }
}
