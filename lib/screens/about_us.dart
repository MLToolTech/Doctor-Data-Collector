import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AboutUs extends StatefulWidget {
  static const String id = 'about_us';
  @override
  _AboutUsState createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About us'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              children: <Widget>[
                SizedBox(
                  height: 15.0,
                ),
                CircleAvatar(
                  radius: 100.0,
                  backgroundColor: Colors.black12,
                  child: Image(
                    image: AssetImage('assets/images/bb.png'),
                  ),
                ),
                SizedBox(
                  height: 15.0,
                ),
                Text(
                  'Doctor Data Collectoer',
                  style: TextStyle(fontSize: 20.0),
                ),
                Text(
                  'Blockchain with Internet of Things - A deadly combination',
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 10.0,
                ),
                Text(
                  '0.0.1',
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 60.0),
              child: Column(
                children: <Widget>[
                  Text(
                    'A RoboMx\u1d40\u1d39 Creation',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                  ),
                  Text(
                    'Powered by Baios Bay',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
