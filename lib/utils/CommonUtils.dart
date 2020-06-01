import 'package:check_price/customWidgets/LoadingDialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CommonUtils {
  static void showLoadingDialog(BuildContext context, String text) {
    showDialog(context: context, builder: (context) => LoadingDialog(text));
  }

  static void showToast(BuildContext context, String text) {
//    Fluttertoast.showToast(
//        msg: text,
//        gravity: ToastGravity.CENTER,
//        backgroundColor: Colors.white,
//        textColor: Colors.black,
//        fontSize: 20
//    );

    showCupertinoDialog(
        context: context,
        builder: (context) {
          return new CupertinoAlertDialog(
            content: new Text(text),
            actions: <Widget>[
              new FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: new Text("確定",
                    style: TextStyle(color: Color(0xff007AFF))),
              ),
            ],
          );
        });
  }
}
