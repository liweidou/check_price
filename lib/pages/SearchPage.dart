import 'package:check_price/pages/PriceListPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with WidgetsBindingObserver {
  TextEditingController nameCtr = TextEditingController();
  FocusNode focusNode = FocusNode(debugLabel: "input");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
       Future.delayed(Duration(milliseconds: 300),()=>  FocusScope.of(context).requestFocus(focusNode));
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        leading: IconButton(
          onPressed: (){
            FocusScope.of(context).unfocus();
            Future.delayed(Duration(milliseconds: 100),
                    () => Navigator.pop(context));
          },
          icon: Icon(Icons.arrow_back_ios,color: Colors.black,),
        ),
        centerTitle: true,
        title: Text("搜索商品"),
      ),
      body: Container(
        width: double.infinity,
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 131),
              child: Hero(
                tag: "title",
                child: FlatButton(
                  child: Text(
                    "全民格價",
                    style: TextStyle(color: Colors.black, fontSize: 34),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20),
              padding: EdgeInsets.only(left: 28, right: 27),
              width: double.infinity,
              child: Stack(
                children: <Widget>[
                  Container(
                    child: TextField(
                      cursorColor: Colors.blue,
                      showCursor: true,
                      onChanged: (str) {
                        setState(() {});
                      },
                      focusNode: focusNode,
                      textAlignVertical: TextAlignVertical.center,
                      controller: nameCtr,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(left: 21, right: 21),
                        suffixIcon: nameCtr.text.isEmpty
                            ? Text("")
                            : IconButton(
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
                        hintText: "請輸入產品名稱",
                        hintStyle:
                            TextStyle(fontSize: 17, color: Color(0xffA6A2BA)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(25),
                                bottomLeft: Radius.circular(25)),
                            borderSide: BorderSide(color: Color(0xff979797))),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(25),
                                bottomLeft: Radius.circular(25)),
                            borderSide: BorderSide(color: Color(0xffF4B400))),
                      ),
                    ),
                    padding: EdgeInsets.only(right: 52),
                    height: 50,
                  ),
                  Positioned(
                    right: 0,
                    child: Container(
                      width: 56,
                      height: 48,
                      child: RaisedButton(
                        color: Color(0xff568AFF),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(27),
                                bottomRight: Radius.circular(27))),
                        onPressed: () {
                          if (!nameCtr.text.isEmpty) {
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => PriceListPage(
                                          productName: nameCtr.text.toString(),
                                        )));
                          }
                        },
                        child: Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
