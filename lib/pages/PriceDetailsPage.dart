import 'package:check_price/pages/ToCorrectPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PriceDetailsPage extends StatefulWidget {
  String product;

  PriceDetailsPage(this.product);

  @override
  _PriceDetailsPageState createState() => _PriceDetailsPageState(product);
}

class _PriceDetailsPageState extends State<PriceDetailsPage> {
  String product;

  _PriceDetailsPageState(this.product);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          product,
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: <Widget>[
          FlatButton(
            onPressed: () async {
              bool isFinish = await Navigator.push(context,
                  CupertinoPageRoute(builder: (context) => ToCorrectPage()));
              if (isFinish) Navigator.pop(context);
            },
            child: Text(
              "纠错",
              style: TextStyle(color: Colors.white, fontSize: 17),
            ),
          )
        ],
      ),
      body: Container(
        width: double.infinity,
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: 98,
              color: Colors.black,
              child: Column(
                children: <Widget>[
                  Container(
                    child: Text(
                      "商店：新苗超市",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    margin: EdgeInsets.only(left: 16, top: 6),
                  ),
                  Container(
                    child: Text(
                      "時間：2020-05-20 23:48:29",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    margin: EdgeInsets.only(left: 16, top: 2),
                  ),
                  Container(
                    child: Text(
                      "價格：\$15.5",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    margin: EdgeInsets.only(left: 16, top: 2),
                  )
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
            ),
            Expanded(
              flex: 1,
              child: Image.asset("images/simple_ticket.jpg"),
            )
          ],
        ),
      ),
    );
  }
}
