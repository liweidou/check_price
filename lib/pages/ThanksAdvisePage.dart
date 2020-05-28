import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ThanksAdvisePage extends StatefulWidget {
  @override
  _ThanksAdvisePageState createState() => _ThanksAdvisePageState();
}

class _ThanksAdvisePageState extends State<ThanksAdvisePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xff4285F4),
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
                  "感謝您寶貴的意見",
                  style: TextStyle(fontSize: 34, color: Colors.white),
                ),
              )),
          Container(
            margin: EdgeInsets.only(top: 12),
            child: FlatButton(
              child: Text(
                "這是我們進步的動力",
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
