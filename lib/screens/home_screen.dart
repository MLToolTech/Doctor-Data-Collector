import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:doc_app/screens/profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as Path;
import 'package:doc_app/screens/patient_details.dart';

final databaseReference = Firestore.instance;

class HomeScreen extends StatefulWidget {
  static const String id = 'home_screen';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;

  String loggedInUser = '';
  String uri =
      'https://pecb.com/conferences/wp-content/uploads/2017/10/no-profile-picture.jpg';
  FirebaseUser uId;
  String _uploadedFileURL;
  var _patientName;
  var _patientPhoneNo;
  var _patientNameController = TextEditingController();
  var _patientPhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
//    _getPatientInfo();
  }

  void _getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        setState(() {
          uId = user;
          loggedInUser = user.email.toString();
          //print(loggedInUser);
        });
        getPhotoFirebase();
      }
    } catch (e) {
      print(e);
    }
  }

  Future getPhotoFirebase() async {
    try {
      //firestore retrieve data
      dynamic a;
      await databaseReference
          .collection("images")
          .document(uId.uid)
          .get()
          .then((DocumentSnapshot ds) {
        //print(ds.data['image']);
        a = ds.data['image'];
      });
      //firebase storage
      StorageReference storageReference =
          FirebaseStorage.instance.ref().child('profiles/${Path.basename(a)}');
      storageReference.getDownloadURL().then((fileURL) {
        if (mounted) {
          setState(() {
            _uploadedFileURL = fileURL;
          });
        }
      });
    } catch (e) {
      print(e);
    }
  }

  Future _createRecord() async {
    try {
      DocumentReference docref =
          databaseReference.collection("patient").document(uId.uid);
      DocumentSnapshot docSnap = await docref.get();
      if (docSnap.exists) {
        await databaseReference
            .collection("patient")
            .document(uId.uid)
            .updateData({
          'patient': FieldValue.arrayUnion([
            {
              'patientName': _patientName,
              'phoneNo': _patientPhoneNo,
            }
          ])
        });
        return;
      }
      await databaseReference.collection("patient").document(uId.uid).setData({
        'patient': FieldValue.arrayUnion([
          {
            'patientName': _patientName,
            'phoneNo': _patientPhoneNo,
          }
        ])
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _neverSatisfied() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        bool _validator = false;
        bool _validator1 = false;
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text('Enter patient details'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextField(
                    controller: _patientNameController,
                    onChanged: (value) {
                      setState(() {
                        _patientName = value;
                      });
                    },
                    decoration: InputDecoration(
                        hintText: 'Enter patient name',
                        labelText: 'Name',
                        errorText: _validator ? 'Required field' : null),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  TextField(
                    controller: _patientPhoneController,
                    onChanged: (value) {
                      setState(() {
                        _patientPhoneNo = value;
                      });
                    },
                    keyboardType: TextInputType.number,
                    maxLength: 10,
                    decoration: InputDecoration(
                        hintText: 'Enter phone no.',
                        labelText: 'Phone',
                        errorText: _validator1 ? 'Required field' : null),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Add'),
                onPressed: () {
                  setState(() {
                    if (_patientNameController.text.isEmpty) {
                      _validator = true;
                    } else if (_patientPhoneController.text.isEmpty) {
                      _validator1 = true;
                    } else {
                      _validator = false;
                      _patientNameController.clear();
                      _patientPhoneController.clear();
                      _createRecord();
                      Navigator.pop(context);
                    }
                  });
                },
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        appBar: AppBar(title: Text('Home')),
        body: Column(
          children: <Widget>[
            StreamWidget(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _neverSatisfied();
          },
          child: Icon(Icons.add),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Column(
                  children: <Widget>[
                    Flexible(
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(_uploadedFileURL ?? uri),
                        backgroundColor: Colors.white,
                        child: Text(''),
                        radius: 40.0,
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(loggedInUser),
                  ],
                ),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              ),
              ListTile(
                title: Text('Profile'),
                leading: Icon(Icons.person),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, ProfileScreen.id);
                },
              ),
              Divider(
                color: Colors.grey,
                height: 10.0,
                indent: 5.0,
                endIndent: 5.0,
              ),
              ListTile(
                title: Text('Logout'),
                leading: Icon(Icons.cancel),
                onTap: () {
                  _auth.signOut();
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StreamWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: databaseReference.collection('patient').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Text('No Patient added'),
          );
        }

        final patientData = snapshot.data.documents;
        dynamic firData;
        for (var i in patientData) {
          firData = i.data['patient'];
        }
        return Expanded(
          child: ListView.builder(
            itemBuilder: (context, position) {
              return Card(
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                PatientDetails(clickPosition: position)));
                  },
                  leading: Icon(Icons.person),
                  title: Text(firData[position]['patientName']),
                  subtitle: Text(firData[position]['phoneNo']),
                ),
              );
            },
            itemCount: firData.length,
          ),
        );
      },
    );
  }
}
