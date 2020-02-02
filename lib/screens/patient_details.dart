import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as Path;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:photo_view/photo_view.dart';

class PatientDetails extends StatefulWidget {
  PatientDetails({@required this.clickPosition});

  static const String id = 'patient_details';
  final int clickPosition;
  @override
  _PatientDetailsState createState() => _PatientDetailsState();
}

class _PatientDetailsState extends State<PatientDetails> {
  File _image;
  final _databaseReference = Firestore.instance;
  final _auth = FirebaseAuth.instance;
  FirebaseUser uId;
  bool showSpinner = false;
  dynamic firImageData;
  List<dynamic> _uploadedFileURL = [];

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        setState(() {
          uId = user;
          //imagesStream();
          getDataFir();
        });
      }
    } catch (e) {
      showSpinner = false;
      print(e);
    }
  }

  Future _getImage() async {
    try {
      var image = await ImagePicker.pickImage(
          source: ImageSource.camera, imageQuality: 50);
      setState(() {
        _image = image;
      });
      _uploadFile();
    } catch (e) {
      showSpinner = false;
      print(e);
    }
  }

  Future _uploadFile() async {
    try {
      setState(() {
        showSpinner = true;
      });
      StorageReference storageReference = FirebaseStorage.instance
          .ref()
          .child('patientImages/${Path.basename(_image.path)}');
      StorageUploadTask uploadTask = storageReference.putFile(_image);
      await uploadTask.onComplete;
      print('File Uploaded');
      await _createRecord();
      await getDataFir();
      setState(() {
        showSpinner = false;
      });
    } catch (e) {
      showSpinner = false;
      print(e);
    }
  }

  Future _createRecord() async {
    try {
      DocumentReference docref =
          _databaseReference.collection("patientImages").document(uId.uid);
      DocumentSnapshot docSnap = await docref.get();
      if (docSnap.exists) {
        await _databaseReference
            .collection("patientImages")
            .document(uId.uid)
            .updateData({
          widget.clickPosition.toString(): FieldValue.arrayUnion([_image.path]),
        });
        return;
      }
      await _databaseReference
          .collection("patientImages")
          .document(uId.uid)
          .setData({
        widget.clickPosition.toString(): FieldValue.arrayUnion([_image.path]),
      });
    } catch (e) {
      showSpinner = false;
      print(e);
    }
  }

  Future getImageUrl() async {
    await _databaseReference
        .collection('patientImages')
        .document(uId.uid)
        .get()
        .then((DocumentSnapshot ds) {
      // print(ds.data);
      firImageData = ds.data['${widget.clickPosition}'];
      //print(firImageData);
    });
  }

  Future<void> getDataFir() async {
    try {
      //get firebase storage
      await getImageUrl();
      _uploadedFileURL.clear();
      for (int i = 0; i < firImageData.length; i++) {
        StorageReference storageReference = FirebaseStorage.instance
            .ref()
            .child('patientImages/${Path.basename(firImageData[i])}');
        storageReference.getDownloadURL().then((fileURL) {
          if (this.mounted) {
            setState(() {
              _uploadedFileURL.add(fileURL);
            });
          }
        });
      }
      //print(firImageData.length);
    } catch (e) {
      showSpinner = false;
      print(e);
    }
  }
/*
  void imagesStream(BuildContext context) async {
    try {
      _databaseReference
          .collection('patientImages')
          .document(uId.uid)
          .snapshots()
          .forEach((s) {
        firImageData = s.data['${widget.clickPosition}'];
      });
      print('2');
      //get firebase storage
      for (int i = 0; i < firImageData.length; i++) {
        StorageReference storageReference = FirebaseStorage.instance
            .ref()
            .child('patientImages/${Path.basename(firImageData[i])}');
        storageReference.getDownloadURL().then((fileURL) {
          if (this.mounted) {
            setState(() {
              _uploadedFileURL.add(fileURL);
            });
          }
        });
      }
      print(_uploadedFileURL);
      print('88888888888888888888888888888888');
    } catch (e) {
      print(e);
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Details'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.ac_unit),
            onPressed: () {
              //imagesStream(context);
            },
          )
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        opacity: 0.8,
        child: Column(
          children: <Widget>[
            Flexible(
              child: GridView.extent(
                  maxCrossAxisExtent: 200.0,
                  mainAxisSpacing: 5.0,
                  crossAxisSpacing: 5.0,
                  addAutomaticKeepAlives: true,
                  padding: EdgeInsets.all(5.0),
                  children: List<Container>.generate(_uploadedFileURL.length,
                      (int index) {
                    return Container(
                      child: Image.network(
                        _uploadedFileURL[index],
                        fit: BoxFit.cover,
                      ),
                    );
                  })),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _getImage();
        },
        label: Text('Add Photo'),
        icon: Icon(Icons.photo_camera),
      ),
    );
  }
}
