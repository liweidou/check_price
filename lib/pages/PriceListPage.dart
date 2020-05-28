import 'dart:convert';

import 'package:check_price/beans/ProductResponeBean.dart';
import 'package:check_price/customWidgets/PopupWindow.dart';
import 'package:check_price/pages/HomePage.dart';
import 'package:check_price/pages/PriceDetailsPage.dart';
import 'package:check_price/utils/Global.dart';
import 'package:check_price/utils/NetworkUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/ball_pulse_footer.dart';
import 'package:flutter_easyrefresh/ball_pulse_header.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PriceListPage extends StatefulWidget {
  String productName;

  PriceListPage({this.productName});

  @override
  _PriceListPageState createState() =>
      _PriceListPageState(productName: productName);
}

class _PriceListPageState extends State<PriceListPage> {
  String productName;
  bool isTodayResluts = true;
  bool isAsec = true;
  bool isSortByTime = true;

  _PriceListPageState({this.productName});

  EasyRefreshController refreshController = EasyRefreshController();

  List<Results> dataList = List();

  List<String> sortTitles = List();

  int currentPage = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    sortTitles.add("按时间排序");
    sortTitles.add("按价格排序");

    onRefreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: EasyRefresh(
        controller: refreshController,
        header: BallPulseHeader(),
        footer: BallPulseFooter(),
        onRefresh: onRefreshData,
        onLoad: onLoadMoreData,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              backgroundColor: Color(0xff4285F4),
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back),
                color: Colors.white,
              ),
              centerTitle: true,
              title: Text(
                productName,
                style: TextStyle(color: Colors.white),
              ),
              floating: true,
              pinned: true,
              snap: true,
              expandedHeight: 100,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  margin: EdgeInsets.only(top: 75),
                  padding: EdgeInsets.only(right: 16),
                  color: Colors.white,
                  width: double.infinity,
                  height: 44,
                  child: Row(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(left: 8),
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              isTodayResluts = !isTodayResluts;
                            });
                          },
                          icon: Icon(
                            Icons.check_box,
                            color: isTodayResluts ? Colors.blue : Colors.grey,
                          ),
                        ),
                      ),
                      Text(
                        "最新結果",
                        style: TextStyle(color: Colors.black, fontSize: 18),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(""),
                      ),
                      InkWell(
                        onTap: () {
                          showDialog(
                              context: context,
                              child: SimpleDialog(
                                title: Text("选择排序方式"),
                                children: <Widget>[
                                  SimpleDialogOption(
                                    child: Text(
                                      "按时间排序",
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        isSortByTime = true;
                                      });
                                      Navigator.pop(context);
                                    },
                                  ),
                                  SimpleDialogOption(
                                    child: Text(
                                      "按价格排序",
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        isSortByTime = false;
                                      });
                                      Navigator.pop(context);
                                    },
                                  )
                                ],
                              ));
                        },
                        child: Row(
                          children: <Widget>[
                            Container(
                              child: Icon(Icons.keyboard_arrow_down),
                              margin: EdgeInsets.only(top: 5),
                            ),
                            Text(
                              isSortByTime ? "按時間排序" : "按价格排序",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 18),
                            ),
                            IconButton(
                              onPressed: () => setState(() {
                                isAsec = !isAsec;
                              }),
                              icon: FaIcon(isAsec
                                  ? FontAwesomeIcons.sortAmountUpAlt
                                  : FontAwesomeIcons.sortAmountDownAlt),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                  (context, index) => GroupItemView(results: dataList[index]),
                  childCount: dataList.length),
            )
          ],
        ),
      ),
    );
  }

  Future<void> onRefreshData() async {
    NetworkUtil.isConnected().then((value) {
      if (value) {
        if (Global.API_TOKEN.isEmpty) {
          NetworkUtil.doLogin(() {
            currentPage = 1;
            NetworkUtil.get(getUrl(), true,
                (respone) {
              ProductResponeBean productResponeBean =
                  ProductResponeBean.fromJson(
                      jsonDecode(Utf8Decoder().convert(respone.bodyBytes)));
              dataList.clear();
              dataList.addAll(productResponeBean.results);
              setState(() {});
            }, (erro) {});
          });
        } else {
          currentPage = 1;
          NetworkUtil.get(getUrl(), true,
              (respone) {
            ProductResponeBean productResponeBean = ProductResponeBean.fromJson(
                jsonDecode(Utf8Decoder().convert(respone.bodyBytes)));
            dataList.clear();
            dataList.addAll(productResponeBean.results);
            setState(() {});
          }, (erro) {});
        }
      } else {
        Fluttertoast.showToast(msg: "請檢查網絡！");
      }
      refreshController.finishRefresh(success: true);
    });
  }

  Future<void> onLoadMoreData() async {
    NetworkUtil.isConnected().then((value) {
      if (value) {
        if (Global.API_TOKEN.isEmpty) {
          NetworkUtil.doLogin(() {
            NetworkUtil.get(getUrl(), true, (respone) {
              currentPage++;
              ProductResponeBean productResponeBean =
                  ProductResponeBean.fromJson(
                      jsonDecode(Utf8Decoder().convert(respone.bodyBytes)));
              dataList.addAll(productResponeBean.results);
              setState(() {});
            }, (erro) {});
          });
        } else {
          NetworkUtil.get(getUrl(), true, (respone) {
            currentPage++;
            ProductResponeBean productResponeBean = ProductResponeBean.fromJson(
                jsonDecode(Utf8Decoder().convert(respone.bodyBytes)));
            dataList.addAll(productResponeBean.results);
            setState(() {});
          }, (erro) {
            NetworkUtil.doLogin(() {
              NetworkUtil.get("/product?page=" + currentPage.toString(), true,
                  (respone) {
                currentPage++;
                ProductResponeBean productResponeBean =
                    ProductResponeBean.fromJson(
                        jsonDecode(Utf8Decoder().convert(respone.bodyBytes)));
                dataList.addAll(productResponeBean.results);
                setState(() {});
              }, (erro) {});
            });
          });
        }
      } else {
        Fluttertoast.showToast(msg: "請檢查網絡！");
      }
      refreshController.finishLoad(success: true, noMore: false);
    });
  }

  String getUrl() {
    String url = "";
    if (isTodayResluts) {
      if (isSortByTime) {
        if (isAsec) {
          url = "/product?page=" +
              currentPage.toString() +
              "&search=" +
              productName +
              "&new=true" +
              "&ordering=product__uploaddate";
        } else {
          url = "/product?page=" +
              currentPage.toString() +
              "&search=" +
              productName +
              "&new=true" +
              "&ordering=-product__uploaddate";
        }
      } else {
        if (isAsec) {
          url = "/product?page=" +
              currentPage.toString() +
              "&search=" +
              productName +
              "&new=true" +
              "&ordering=-product__price";
        } else {
          url = "/product?page=" +
              currentPage.toString() +
              "&search=" +
              productName +
              "&new=true" +
              "&ordering=product__price";
        }
      }
    } else {
      if (isSortByTime) {
        if (isAsec) {
          url = "/product?page=" +
              currentPage.toString() +
              "&search=" +
              productName +
              "&ordering=product__uploaddate";
        } else {
          url = "/product?page=" +
              currentPage.toString() +
              "&search=" +
              productName +
              "&ordering=-product__uploaddate";
        }
      } else {
        if (isAsec) {
          url = "/product?page=" +
              currentPage.toString() +
              "&search=" +
              productName +
              "&ordering=-product__price";
        } else {
          url = "/product?page=" +
              currentPage.toString() +
              "&search=" +
              productName +
              "&ordering=product__price";
        }
      }
    }
    return url;
  }
}


class GroupItemView extends StatelessWidget {
  Results results;

  GroupItemView({this.results});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            color: Color(0xff4285F4),
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 16, top: 0, right: 16, bottom: 0),
            width: double.infinity,
            height: 33,
            child: Text(
              results.name,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  decoration: TextDecoration.none),
            ),
          ),
          Divider(
            height: 1,
          ),
          MediaQuery.removePadding(
            removeTop: true,
            context: context,
            child: ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, i) =>
                    ChildIteView(results.product[i], results.name),
                separatorBuilder: (context, i) => Divider(
                      height: 1,
                    ),
                itemCount: results.product.length),
          )
        ],
      ),
    );
  }
}

class ChildIteView extends StatelessWidget {
  Product item;
  String address;
  GlobalKey popuImageKey = GlobalKey(debugLabel: "popuImage");

  ChildIteView(Product item, String address) {
    this.item = item;
    this.address = address;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Material(
      child: InkWell(
        key: popuImageKey,
        onLongPress: () {
          PopupWindow.showPopWindow(
              context,
              "bottom",
              popuImageKey,
              PopDirection.bottom,
              Container(
                width: 200,
                height: 100,
                child: item.image.length == 0
                    ? Text("")
                    : Image.network(item.image[0].imageurl),
              ),
              -70);
        },
        onTap: () {
          Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) => PriceDetailsPage(item, address)));
        },
        child: Container(
          width: double.infinity,
          height: 75,
          child: Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: Text(item.name,
                          style: TextStyle(color: Colors.black, fontSize: 21)),
                      margin: EdgeInsets.only(top: 10),
                    ),
                    Container(
                      child: Text(
                        "2020-05-20 23:48:29",
                        style:
                            TextStyle(color: Color(0xff0F9D58), fontSize: 14),
                      ),
                      margin: EdgeInsets.only(top: 5),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(""),
              ),
              Text(
                "\$55.5",
                style: TextStyle(color: Color(0xff4285F4), fontSize: 24),
              ),
              Container(
                margin: EdgeInsets.only(right: 15),
                child: Icon(Icons.keyboard_arrow_right),
              )
            ],
          ),
        ),
      ),
    );
  }
}
