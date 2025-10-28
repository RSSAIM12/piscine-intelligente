import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/firebase_config.dart';
import 'pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: FirebaseConfig.firebaseConfig["apiKey"]!,
      authDomain: FirebaseConfig.firebaseConfig["authDomain"]!,
      projectId: FirebaseConfig.firebaseConfig["projectId"]!,
      storageBucket: FirebaseConfig.firebaseConfig["storageBucket"]!,
      messagingSenderId: FirebaseConfig.firebaseConfig["messagingSenderId"]!,
      appId: FirebaseConfig.firebaseConfig["appId"]!,
    ),
  );
  runApp(PoolMasterApp());
}

class PoolMasterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PoolMaster - Piscine Intelligente',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}