import 'package:doc_app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:doc_app/screens/registration_screen.dart';
import 'package:doc_app/screens/login_screen.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:doc_app/components/round_button.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcome_screen';
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  final _auth = FirebaseAuth.instance;
  @override
  void initState() {
    super.initState();
    getUser();
  }

  void getUser() async {
    final user = await _auth.currentUser();
    if (user != null) {
      Navigator.pushReplacementNamed(context, HomeScreen.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Hero(
                tag: 'icon',
                child: Container(
                  child: Icon(
                    Icons.local_hospital,
                    color: Colors.red,
                    size: 60.0,
                  ),
                ),
              ),
              TypewriterAnimatedTextKit(
                totalRepeatCount: 4,
                speed: Duration(seconds: 1),
                text: ['Doctor app'],
                textStyle: TextStyle(
                  fontSize: 45.0,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 48.0,
          ),
          RoundedButton(
            colour: Colors.redAccent,
            title: 'Log In',
            onPressed: () {
              Navigator.pushNamed(context, LoginScreen.id);
            },
          ),
          RoundedButton(
            colour: Color(0xFFff1744),
            title: 'Register',
            onPressed: () {
              Navigator.pushNamed(context, RegistrationScreen.id);
            },
          ),
        ],
      ),
    );
  }
}
