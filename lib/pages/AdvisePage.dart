import 'dart:convert';

import 'package:check_price/customWidgets/LoadingDialog.dart';
import 'package:check_price/pages/ThanksAdvisePage.dart';
import 'package:check_price/utils/CommonUtils.dart';
import 'package:check_price/utils/NetworkUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AdvisePage extends StatefulWidget with WidgetsBindingObserver{
  @override
  _AdvisePageState createState() => _AdvisePageState();
}

class _AdvisePageState extends State<AdvisePage> {
  TextEditingController contentCtr = TextEditingController();
  FocusNode focusNode = FocusNode(debugLabel: "input");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      FocusScope.of(context).requestFocus(focusNode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: Text("意見回饋"),
        actions: <Widget>[
          FlatButton(
            child: Text("確定",
                style: TextStyle(color: Color(0xff007AFF), fontSize: 17)),
            onPressed: () {
              postAdvise(contentCtr.text);
            },
          )
        ],
      ),
      body: Container(
        color: Color(0xfff3f3f3),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 16, top: 20),
              child: Text(
                "請在下方輸入你寶貴的意見。",
                style: TextStyle(color: Colors.black, fontSize: 17),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 13,bottom: 13),
              color: Colors.white,
              child: TextField(
                maxLines: null,
                keyboardType: TextInputType.multiline,
                focusNode: focusNode,
                autofocus: true,
                controller: contentCtr,
                decoration: InputDecoration(
                  hintText: "内容",
                  contentPadding: EdgeInsets.only(left: 16,bottom: 16,top: 16),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent)),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void postAdvise(String text) async {
    var params = {"text": text};
    var body = utf8.encode(jsonEncode(params));
    showDialog(
        context: context, builder: (context) => LoadingDialog("正在提交意見..."));
    await NetworkUtil.postWithBody("/api/comment/create", body, true,
        (respone) {
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.push(context,
          CupertinoPageRoute(builder: (context) => ThanksAdvisePage()));
    }, (erro) {
      Navigator.pop(context);
      CommonUtils.showToast(context,"提交意見失敗！");
    });
  }
}
