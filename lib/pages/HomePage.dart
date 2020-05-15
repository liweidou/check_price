import 'dart:io';

import 'package:check_price/pages/SearchPage.dart';
import 'package:check_price/pages/UploadPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 199),
              child: Text(
                "全民格價",
                style: TextStyle(color: Colors.black, fontSize: 34),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 30),
              child: Text(
                "大家一起捍衛合理的自由市場",
                style: TextStyle(color: Colors.black, fontSize: 17),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 263),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Text(""),
                  ),
                  Container(
                    width: 120,
                    height: 120,
                    child: RaisedButton(
                      onPressed:  () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => UploadPage()));
                      },
                      color: Color(0xff003153),
                      child: Icon(
                        Icons.camera_enhance,
                        color: Colors.white,
                        size: 74,
                      ),
                    ),
                  ),
                  Container(
                    width: 120,
                    height: 120,
                    margin: EdgeInsets.only(left: 40),
                    child: RaisedButton(
                      onPressed:  () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => SearchPage()));
                      },
                      color: Color(0xff568AFF),
                      child: Icon(
                        Icons.search,
                        color: Colors.white,
                        size: 74,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(""),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(""),
            ),
          ],
        ),
      ),
    );
  }
}
