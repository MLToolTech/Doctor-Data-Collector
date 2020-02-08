import 'package:doc_app/screens/about_us.dart';
import 'package:doc_app/screens/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:doc_app/screens/profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as Path;
import 'package:doc_app/screens/patient_details.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:doc_app/constants.dart';

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
  List<dynamic> patientArray = [];
  bool _showSpinner = false;
  dynamic imgUrl;
  DocumentSnapshot docSnap;

  @override
  void initState() {
    super.initState();
    FirebaseAdMob.instance.initialize(appId: FirebaseAdMob.testAppId);
    myBanner
      ..load()
      ..show();
    _getCurrentUser();
//    _getPatientInfo();
  }

  @override
  void dispose() {
    myBanner.dispose();
    super.dispose();
  }

  void _getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        setState(() {
          uId = user;
          loggedInUser = user.email.toString();

          getPatient();
          //print(loggedInUser);
        });
        docSnap = await databaseReference
            .collection('patient')
            .document(uId.uid)
            .get();
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
      _showSpinner = true;
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
        await getPatient();
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
      await getPatient();
      _showSpinner = false;
    } catch (e) {
      _showSpinner = false;
      print(e);
    }
  }

  Future getPatient() async {
    try {
      await databaseReference
          .collection('patient')
          .document(uId.uid)
          .get()
          .then((DocumentSnapshot ds) {
        setState(() {
          patientArray = List<dynamic>.from(ds.data['patient']);
        });

        //print(patientArray);
        //print(patientArray.length);
      });
    } catch (e) {
      _showSpinner = false;
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
                child: Text(
                  'Add',
                  style: TextStyle(
                    color: Color(0xFFff1744),
                  ),
                ),
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

  Future _getImageUrl(int pos) async {
    await databaseReference
        .collection('patientImages')
        .document(uId.uid)
        .get()
        .then((DocumentSnapshot ds) {
      // print(ds.data);
      imgUrl = List<dynamic>.from(ds.data['$pos']);
      //print(firImageData);
    });
  }

  void deletePatient(int pos) async {
    try {
      _showSpinner = true;
      _getImageUrl(pos);
      await databaseReference
          .collection("patient")
          .document(uId.uid)
          .updateData({
        'patient': FieldValue.arrayRemove([
          {
            'patientName': patientArray[pos]['patientName'],
            'phoneNo': patientArray[pos]['phoneNo'],
          }
        ])
      });
      setState(() {
        patientArray.removeAt(pos);
      });
      // delete images
      await databaseReference
          .collection("patientImages")
          .document(uId.uid)
          .updateData({
        pos.toString(): FieldValue.delete(),
      });
      // delete firstorage photos
      for (int i = 0; i < imgUrl.length; i++) {
        StorageReference storageReference = FirebaseStorage.instance
            .ref()
            .child('patientImages/${Path.basename(imgUrl[pos])}');
        await storageReference.delete();
      }
      _showSpinner = false;
    } catch (e) {
      _showSpinner = false;
      print('dsfsdfs $e');
    }
  }

  Widget bodyOfScreen() {
    if (patientArray.length == 0) {
      return Center(
        child: Text('No patient'),
      );
    } else {
      return Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, position) {
                return Card(
                  elevation: 5.0,
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  PatientDetails(clickPosition: position)));
                    },
                    leading: Icon(Icons.person),
                    title: Text(patientArray[position]['patientName']),
                    subtitle: Text(patientArray[position]['phoneNo']),
                    trailing: GestureDetector(
                      child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 10.0),
                          child: Icon(Icons.delete_forever)),
                      onTap: () {
                        deletePatient(position);
                        _showSpinner = false;
                      },
                    ),
                  ),
                );
              },
              itemCount: patientArray.length,
            ),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _showSpinner,
        child: bodyOfScreen(),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50.0, right: 0.0),
        child: FloatingActionButton(
          backgroundColor: Color(0xFFff1744),
          onPressed: () {
            _neverSatisfied();
          },
          child: Icon(Icons.add),
        ),
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
                color: Color(0xFFff1744),
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
            kDivider,
            ListTile(
              title: Text('About us'),
              leading: Icon(Icons.supervisor_account),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AboutUs.id);
              },
            ),
            kDivider,
            ListTile(
              title: Text('Logout'),
              leading: Icon(Icons.cancel),
              onTap: () {
                _auth.signOut();
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, LoginScreen.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
// banner ads

MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
  keywords: <String>['Medical', 'Doctor'],
  childDirected: false, // or MobileAdGender.female, MobileAdGender.unknown
  testDevices: <String>[], // Android emulators are considered test devices
);

BannerAd myBanner = BannerAd(
  adUnitId: BannerAd.testAdUnitId,
  size: AdSize.banner,
  targetingInfo: targetingInfo,
  listener: (MobileAdEvent event) {
    //print("BannerAd event is $event");
  },
);
