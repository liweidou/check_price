import 'package:check_price/customWidgets/PopupWindow.dart';
import 'package:check_price/pages/PriceDetailsPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/ball_pulse_footer.dart';
import 'package:flutter_easyrefresh/ball_pulse_header.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
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
  bool isTodayResluts = false;
  bool isAsec = true;
  bool isSortByTime = true;

  _PriceListPageState({this.productName});

  EasyRefreshController refreshController = EasyRefreshController();

  List<List<String>> dataList = List();

  List<String> sortTitles = List();

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
                onPressed: ()=> Navigator.pop(context),
                icon: Icon(Icons.arrow_back),
                color: Colors.white,
              ),
              centerTitle: true,
              title: Text(productName,style: TextStyle(color: Colors.white),),
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
                      Text("最新結果",style: TextStyle(color: Colors.black,fontSize: 18),),
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
                  (context, index) => GroupItemView(datalist: dataList[index]),
                  childCount: dataList.length),
            )
          ],
        ),
      ),
    );
  }

  Future<void> onRefreshData() async {
    await Future.delayed(Duration(seconds: 1), () {
      dataList.clear();
      for (int i = 0; i < 3; i++) {
        List<String> addlist = List();
        for (int j = 0; j < 3; j++) {
          addlist.add("合味道咖喱味");
        }
        dataList.add(addlist);
      }
      setState(() {});
      refreshController.finishRefresh(success: true);
    });
  }

  Future<void> onLoadMoreData() async {
    await Future.delayed(Duration(seconds: 1), () {
      for (int i = 0; i < 3; i++) {
        List<String> addlist = List();
        for (int j = 0; j < 3; j++) {
          addlist.add("合味道咖喱味");
        }
        dataList.add(addlist);
      }
      setState(() {});
      refreshController.finishLoad(success: true, noMore: false);
    });
  }
}

class GroupItemView extends StatelessWidget {
  List<String> datalist;

  GroupItemView({this.datalist});

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
              "嘉荣超市",
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
                itemBuilder: (context, i) => ChildIteView(datalist[i]),
                separatorBuilder: (context, i) => Divider(
                      height: 1,
                    ),
                itemCount: datalist.length),
          )
        ],
      ),
    );
  }
}

class ChildIteView extends StatelessWidget {
  String item;
  GlobalKey popuImageKey = GlobalKey(debugLabel: "popuImage");

  ChildIteView(String item) {
    this.item = item;
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
                child: Image.asset("images/simple_ticket.jpg"),
              ),
              -70);
        },
        onTap: () {
          Navigator.push(context,
              CupertinoPageRoute(builder: (context) => PriceDetailsPage(item)));
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
                      child: Text(item,
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
