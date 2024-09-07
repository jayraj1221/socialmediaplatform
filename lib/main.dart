import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:socialmediaplatform/screens/login_screen.dart';
import 'package:socialmediaplatform/screens/signup_screen.dart';
import 'firebase_options.dart';
void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   name: 'SocialMediaPlatform',
  //   options: const FirebaseOptions(
  //     apiKey:
  //     "AIzaSyA9TebeJ4Vic4CfjB_9LQtYFaG30XMojMQ", // paste your api key here
  //     appId:
  //     "1:195449166114:android:4e4bcce70e13fcf88fad7b", //paste your app id here
  //     messagingSenderId: "195449166114", //paste your messagingSenderId here
  //     projectId: "socialmediaplatform-9c39a",
  //     storageBucket: "socialmediaplatform-9c39a.appspot.com",//paste your project id here
  //   ),
  // );
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options:
  DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Social Media App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(), // Add your SignupScreen route here
        '/home': (context) => HomeScreen(), // Replace with your home screen route
      },
    );
  }
}
