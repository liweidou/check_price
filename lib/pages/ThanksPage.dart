import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ThanksPage extends StatefulWidget {
  @override
  _ThanksPageState createState() => _ThanksPageState();
}

class _ThanksPageState extends State<ThanksPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xffF4B400),
      child: Column(
        children: <Widget>[
          Container(
            margin:
                EdgeInsets.only(top: MediaQuery.of(context).size.height / 6),
            child: FaIcon(
              FontAwesomeIcons.handshake,
              size: 150,
              color: Colors.white,
            ),
          ),
          Container(
              margin: EdgeInsets.only(top: 10),
              child: FlatButton(
                child: Text(
                  "感謝您出的一分力",
                  style: TextStyle(fontSize: 34, color: Colors.white),
                ),
              )),
          Container(
            margin: EdgeInsets.only(top: 12),
            child: FlatButton(
              child: Text(
                "已成功上傳收據",
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 62),
            child: FlatButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "返回",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
