import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as Path;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flushbar/flushbar.dart';

class ProfileScreen extends StatefulWidget {
  static const String id = 'profile_screen';
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String uri =
      'https://pecb.com/conferences/wp-content/uploads/2017/10/no-profile-picture.jpg';
  final _auth = FirebaseAuth.instance;
  final databaseReference = Firestore.instance;
  String loggedInUser = '';
  File _image;
  String _uploadedFileURL;
  bool showSpinner = false;
  FirebaseUser uId;
  bool _status = false;
  var _nameofuser = TextEditingController();
  var _emailofuser = TextEditingController();
  var _userNameValue;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  Future getImage() async {
    try {
      var image = await ImagePicker.pickImage(
          source: ImageSource.gallery, imageQuality: 20);
      setState(() {
        _image = image;
      });
    } catch (e) {
      print(e);
    }
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        setState(() {
          uId = user;
          loggedInUser = user.email.toString();
          _emailofuser.text = loggedInUser;
        });
        getPhotoFirebase();
      }
    } catch (e) {
      print(e);
    }
  }

  Future uploadFile() async {
    try {
      StorageReference storageReference = FirebaseStorage.instance
          .ref()
          .child('profiles/${Path.basename(_image.path)}');
      StorageUploadTask uploadTask = storageReference.putFile(_image);
      await uploadTask.onComplete;
      print('File Uploaded');
    } catch (e) {
      print(e);
    }
  }

  Future _createRecord() async {
    try {
      if (_image == null) {
        await databaseReference.collection("images").document(uId.uid).setData({
          'name': _userNameValue,
        });
      } else {
        await databaseReference.collection("images").document(uId.uid).setData({
          'image': _image.path,
          'name': _userNameValue,
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future getPhotoFirebase() async {
//firestore retrieve data
    try {
      dynamic a;
      await databaseReference
          .collection("images")
          .document(uId.uid)
          .get()
          .then((DocumentSnapshot ds) {
        a = ds.data['image'];
        _nameofuser.text = ds.data['name'];
      });
      //get firebase storage
      StorageReference storageReference =
          FirebaseStorage.instance.ref().child('profiles/${Path.basename(a)}');
      storageReference.getDownloadURL().then((fileURL) {
        setState(() {
          _uploadedFileURL = fileURL;
        });
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: SafeArea(
          child: ListView(
            children: <Widget>[
              Column(
                children: <Widget>[
                  SizedBox(
                    height: 20.0,
                  ),
                  GestureDetector(
                    child: Container(
                      child: _image == null
                          ? CircleAvatar(
                              backgroundImage:
                                  NetworkImage(_uploadedFileURL ?? uri),
                              backgroundColor: Colors.white,
                              radius: 100.0,
                            )
                          : CircleAvatar(
                              backgroundImage: FileImage(_image),
                              backgroundColor: Colors.white,
                              child: Text(''),
                              radius: 100.0,
                            ),
                    ),
                    onTap: () {
                      getImage();
                    },
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  GestureDetector(
                    onTap: () {
                      getImage();
                    },
                    child: Text(
                      'Change profile image ',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w300,
                          color: Colors.lightBlue),
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Personal Information',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        FlatButton(
                          onPressed: () {
                            setState(() {
                              _status = true;
                            });
                          },
                          child: Text(
                            "Edit",
                            style: TextStyle(
                              color: Colors.lightBlue,
                              fontSize: 20,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20.0, right: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextField(
                          controller: _emailofuser,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              disabledBorder: InputBorder.none),
                          enabled: false,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20.0, right: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 27.0,
                        ),
                        Text(
                          'Name',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextField(
                          controller: _nameofuser,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              disabledBorder: InputBorder.none),
                          enabled: _status,
                          onChanged: (value) {
                            _userNameValue = value;
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 70.0,
                  ),
                  RaisedButton(
                    onPressed: () async {
                      setState(() {
                        showSpinner = true;
                      });
                      await uploadFile();
                      _createRecord();
                      Flushbar(
                        title: "Status",
                        message: 'Your profile has been saved',
                        duration: Duration(seconds: 3),
                      ).show(context);

                      setState(() {
                        _status = false;
                        showSpinner = false;
                      });
                    },
                    child: Text('Save'),
                    color: Colors.lightBlueAccent,
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
