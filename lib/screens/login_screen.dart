import 'package:flutter/material.dart';
import 'package:doc_app/components/round_button.dart';
import 'package:doc_app/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:doc_app/screens/home_screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flushbar/flushbar.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;
  String email;
  String password;
  dynamic _exception;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'icon',
                  child: Container(
                    height: 200.0,
                    child: Icon(
                      Icons.local_hospital,
                      color: Colors.red,
                      size: 200.0,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                onChanged: (value) {
                  email = value;
                },
                keyboardType: TextInputType.emailAddress,
                decoration: kFieldDecoration.copyWith(
                  hintText: 'Enter your email',
                  labelText: 'Email',
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                obscureText: true,
                onChanged: (value) {
                  password = value;
                },
                decoration: kFieldDecoration.copyWith(
                  hintText: 'Enter your password',
                  labelText: 'Password',
                ),
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                onPressed: () async {
                  setState(() {
                    showSpinner = true;
                  });
                  try {
                    final user = await _auth.signInWithEmailAndPassword(
                        email: email, password: password);
                    if (user != null) {
                      Navigator.pushReplacementNamed(context, HomeScreen.id);
                    }
                    setState(() {
                      showSpinner = false;
                    });
                  } catch (e) {
                    setState(() {
                      showSpinner = false;
                    });
                    print(e);
                    _exception = e.toString().split(',')[1].split('.')[0];
                    Flushbar(
                      title: "Status",
                      message: _exception,
                      duration: Duration(seconds: 3),
                    ).show(context);
                  }
                },
                title: 'Log In',
                colour: Colors.redAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
