import 'package:doc_app/constants.dart';
import 'package:flutter/material.dart';
import 'package:doc_app/components/round_button.dart';
import 'package:doc_app/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flushbar/flushbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RegistrationScreen extends StatefulWidget {
  static const String id = 'registration_screen';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;
  String email;
  String password;
  dynamic _exception;
  var _emailtxt = TextEditingController();
  var _passwordtxt = TextEditingController();
  bool _checkBoxValue = false;

  Future localDataStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final storage = FlutterSecureStorage();
    await storage.write(key: 'usernamePref', value: email);
    await storage.write(key: 'passwordPef', value: password);

//    prefs.setString('usernamePref', email);
//    prefs.setString('passwordPef', password);
    prefs.setBool('checkBoxStatus', _checkBoxValue);
    print('data stored');
  }

  Future localDataGet() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final storage = FlutterSecureStorage();
//    String prefEmail = prefs.getString('usernamePref');
//    String prefPassword = prefs.getString('passwordPef');
      String storageEmail = await storage.read(key: 'usernamePref');
      String storagePassword = await storage.read(key: 'passwordPef');
      bool prefCheck = prefs.getBool('checkBoxStatus');
      if (prefCheck) {
        _emailtxt.text = storageEmail;
        _passwordtxt.text = storagePassword;
      }

      setState(() {
        _checkBoxValue = prefCheck;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    localDataGet();
  }

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
                controller: _emailtxt,
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  setState(() {
                    email = value;
                  });
                },
                decoration: kFieldDecoration.copyWith(
                  hintText: 'Enter your email',
                  labelText: 'Email',
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                controller: _passwordtxt,
                obscureText: true,
                onChanged: (value) {
                  setState(() {
                    password = value;
                  });
                },
                decoration: kFieldDecoration.copyWith(
                  hintText: 'Enter your password',
                  labelText: 'Password',
                ),
              ),
              Row(
                children: <Widget>[
                  Checkbox(
                      value: _checkBoxValue,
                      onChanged: (bool value) async {
                        setState(() {
                          _checkBoxValue = value;
                        });
                      }),
                  Text('Remember me'),
                ],
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
                    final newUser = await _auth.createUserWithEmailAndPassword(
                        email: email, password: password);
                    if (newUser != null) {
                      if (_checkBoxValue) {
                        await localDataStorage();
                      }
                      Navigator.pushReplacementNamed(context, HomeScreen.id);
                    }
                    setState(() {
                      showSpinner = false;
                    });
                  } catch (e) {
                    setState(() {
                      showSpinner = false;
                    });
                    _exception = e.toString().split(',')[1].split('.')[0];
                    print(e);
                    Flushbar(
                      title: "Status",
                      message: _exception,
                      duration: Duration(seconds: 3),
                    ).show(context);
                  }
                },
                title: 'Register',
                colour: Colors.blueAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
