import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ToCorrectPage extends StatefulWidget {
  @override
  _ToCorrectPageState createState() => _ToCorrectPageState();
}

class _ToCorrectPageState extends State<ToCorrectPage> {
  TextEditingController priceCtr = TextEditingController();
  TextEditingController addressCtr = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: Text("資料糾錯"),
        actions: <Widget>[
          FlatButton(
            onPressed: (){
              Navigator.pop(context,true);
            },
            child: Text("確定",style: TextStyle(color: Color(0xff007AFF),fontSize: 17),),
          )
        ],
      ),
      body: Container(
        width: double.infinity,
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 16,top: 16),
              child: Text("資料會在確認後便會修改。",style: TextStyle(color: Colors.black,fontSize: 17),),
            ),
            Container(
              margin: EdgeInsets.only(top: 16),
              child: TextField(
                textAlignVertical: TextAlignVertical.center,
                controller: priceCtr,
                keyboardType: TextInputType.text,
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
                  hintStyle:
                  TextStyle(fontSize: 17, color: Color(0xffA6A2BA)),
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
                textAlignVertical: TextAlignVertical.center,
                controller: addressCtr,
                keyboardType: TextInputType.text,
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
                  hintStyle:
                  TextStyle(fontSize: 17, color: Color(0xffA6A2BA)),
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
}
