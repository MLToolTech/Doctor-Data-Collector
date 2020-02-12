import 'package:flutter/material.dart';
import 'package:doc_app/screens/welcome_screen.dart';
import 'package:doc_app/screens/login_screen.dart';
import 'package:doc_app/screens/registration_screen.dart';
import 'package:doc_app/screens/home_screen.dart';
import 'package:doc_app/screens/profile_screen.dart';
import 'package:doc_app/splash_screen.dart';
import 'package:doc_app/screens/about_us.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFFff1744),
        accentColor: Colors.redAccent,
      ),
      initialRoute: SlashScreen.id,
      routes: {
        SlashScreen.id: (context) => SlashScreen(),
        WelcomeScreen.id: (context) => WelcomeScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
        HomeScreen.id: (context) => HomeScreen(),
        ProfileScreen.id: (context) => ProfileScreen(),
        AboutUs.id: (context) => AboutUs(),
      },
    );
  }
}
