import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController nameCtr = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: Text("搜索商品"),
      ),
      body: Container(
        width: double.infinity,
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 131),
              child: Text(
                "全民格價",
                style: TextStyle(color: Colors.black, fontSize: 34),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20),
              padding: EdgeInsets.only(left: 20,right: 10),
              width: double.infinity,
              color: Colors.white,
              child: TextField(
                controller: nameCtr,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        nameCtr.text = "";
                      });
                    },
                    icon: Icon(
                      Icons.cancel,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
                  hintText: "輸入產品名稱",
                  hintStyle:
                  TextStyle(fontSize: 17, color: Color(0xffA6A2BA)),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent)),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 50),
              child: FloatingActionButton(
                onPressed: () {

                },
                backgroundColor: Color(0xff568AFF),
                child: Icon(
                  Icons.search,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
