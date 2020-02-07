import 'dart:async';

import 'package:flutter/material.dart';
import 'package:doc_app/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:doc_app/screens/welcome_screen.dart';

class SlashScreen extends StatefulWidget {
  static const String id = 'splash_screen';
  @override
  _SlashScreenState createState() => _SlashScreenState();
}

class _SlashScreenState extends State<SlashScreen> {
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
  }

  startTime() async {
    var _duration = new Duration(seconds: 2);
    return Timer(_duration, navigationPage);
  }

  void navigationPage() {
    Navigator.pushReplacementNamed(context, WelcomeScreen.id);
  }

  void getUser() async {
    final user = await _auth.currentUser();
    if (user != null) {
      Navigator.pushReplacementNamed(context, HomeScreen.id);
    } else {
      startTime();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Image.asset('assets/icon.png'),
          ),
        ),
      ),
    );
  }
}
