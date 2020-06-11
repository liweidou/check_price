import 'dart:convert';

import 'package:check_price/beans/ProductResponeBean.dart';
import 'package:check_price/customWidgets/LoadingDialog.dart';
import 'package:check_price/utils/CommonUtils.dart';
import 'package:check_price/utils/Global.dart';
import 'package:check_price/utils/NetworkUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ToCorrectPage extends StatefulWidget {
  Product product;

  ToCorrectPage(this.product);

  @override
  _ToCorrectPageState createState() => _ToCorrectPageState(product);
}

class _ToCorrectPageState extends State<ToCorrectPage> with WidgetsBindingObserver{
  TextEditingController priceCtr = TextEditingController();
  TextEditingController addressCtr = TextEditingController();
  Product product;
  FocusNode focusNode = FocusNode(debugLabel: "input");

  _ToCorrectPageState(this.product);

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
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: Text("資料糾錯"),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              postCorrection();
            },
            child: Text(
              "確定",
              style: TextStyle(color: Color(0xff007AFF), fontSize: 17),
            ),
          )
        ],
      ),
      body: Container(
        width: double.infinity,
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 16, top: 16),
              child: Text(
                "資料會在確認後便會修改。",
                style: TextStyle(color: Colors.black, fontSize: 17),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 16),
              child: TextField(
                focusNode: focusNode,
                autofocus: true,
                cursorColor: Colors.blue,
                showCursor: true,
                textAlignVertical: TextAlignVertical.center,
                controller: priceCtr,
                keyboardType: TextInputType.number,
                maxLength: 5,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(left: 21, right: 21),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        priceCtr.text = "";
                      });
                    },
                    icon: Icon(
                      Icons.cancel,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
                  hintText: "價格",
                  hintStyle: TextStyle(fontSize: 17, color: Color(0xffA6A2BA)),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent)),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 16),
              child: TextField(
                cursorColor: Colors.blue,
                showCursor: true,
                textAlignVertical: TextAlignVertical.center,
                controller: addressCtr,
                keyboardType: TextInputType.text,
                maxLength: 20,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(left: 21, right: 21),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        addressCtr.text = "";
                      });
                    },
                    icon: Icon(
                      Icons.cancel,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
                  hintText: "地点",
                  hintStyle: TextStyle(fontSize: 17, color: Color(0xffA6A2BA)),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void postCorrection() async {
    showDialog(
        context: context, builder: (context) => LoadingDialog("正在提交糾錯..."));
    print("productid:" + product.id.toString());
    var params = {"product" : product.id ,"price": priceCtr.text, "location": addressCtr.text};
    var body = utf8.encode(jsonEncode(params));
    await NetworkUtil.postWithBody("/api/correction/create", body, true,
        (respone) {
      Navigator.pop(context);
      Navigator.pop(context,true);
    }, (erro) {
      Navigator.pop(context);
      if(erro.statusCode == 401){
        NetworkUtil.doLogin((){
          postCorrection();
        });
      }else if(erro.statusCode == 400){
        Global.preferences.setString(Global.REFRESH_TOKEN_KEY, "");
        NetworkUtil.doLogin((){
          postCorrection();
        });
      }else{
        CommonUtils.showToast(context,"提交糾錯失敗！");
      }

    });
  }
}
