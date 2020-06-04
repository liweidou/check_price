import 'package:check_price/beans/ProductResponeBean.dart';
import 'package:check_price/pages/ToCorrectPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PriceDetailsPage extends StatefulWidget {
  String address;
  Product product;

  PriceDetailsPage(this.product, this.address);

  @override
  _PriceDetailsPageState createState() =>
      _PriceDetailsPageState(product, address);
}

class _PriceDetailsPageState extends State<PriceDetailsPage> {
  Product product;
  String address;

  _PriceDetailsPageState(this.product, this.address);

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
          product.name,
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: <Widget>[
          FlatButton(
            onPressed: () async {
              bool isFinish = await Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (context) => ToCorrectPage(product)));
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
                      "商店：" + address,
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    margin: EdgeInsets.only(left: 16, top: 6),
                  ),
                  Container(
                    child: Text(
                      "時間：" + getFormatStr(product.uploaddate),
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    margin: EdgeInsets.only(left: 16, top: 2),
                  ),
                  Container(
                    child: Text(
                      "價格：\$" + product.price,
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
              child: product.image.length == 0
                  ? Text("")
                  : PhotoView(
                imageProvider: NetworkImage(product.image[0].imageurl),
              ),
            )
//            Expanded(
//              flex: 1,
//              child: product.image.length == 0
//                  ? Text("")
//                  : Image.network(product.image[0].imageurl),
//            )
          ],
        ),
      ),
    );
  }

  String getFormatStr(String datetime) {
    String result = DateTime.parse(product.uploaddate).toString();
    result = result.substring(0, result.indexOf("."));
    return result;
  }
}
