import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
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

  void getUser() async {
    final user = await _auth.currentUser();
    if (user != null) {
      Navigator.pushNamed(context, HomeScreen.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 1,
      navigateAfterSeconds: WelcomeScreen(),
      title: new Text(
        'Welcome In Docapp',
        style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
      ),
      image: new Image.network(
          'https://flutter.io/images/catalog-widget-placeholder.png'),
      gradientBackground: new LinearGradient(
          colors: [Colors.cyan, Colors.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight),
      backgroundColor: Colors.white,
      styleTextUnderTheLoader: new TextStyle(),
      photoSize: 100.0,
      onClick: () => print("Flutter Egypt"),
      loaderColor: Colors.red,
    );
  }
}
