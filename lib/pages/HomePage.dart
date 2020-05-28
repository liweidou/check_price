import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:check_price/beans/CounterResponeBean.dart';
import 'package:check_price/beans/LoginResponeBean.dart';
import 'package:check_price/beans/RefreshTokenResponeBean.dart';
import 'package:check_price/customWidgets/Camera.dart';
import 'package:check_price/customWidgets/CameraFocus.dart';
import 'package:check_price/customWidgets/LoadingDialog.dart';
import 'package:check_price/pages/AdvisePage.dart';
import 'package:check_price/pages/SearchPage.dart';
import 'package:check_price/pages/UploadPage.dart';
import 'package:check_price/utils/Global.dart';
import 'package:check_price/utils/NetworkUtil.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_guidance_plugin/flutter_guidance_plugin.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:imei_plugin/imei_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

const String testDevice = 'A875A9628D17D640CBC6BDED183ECB0C';

class _HomePageState extends State<HomePage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    testDevices: testDevice != null ? <String>[testDevice] : null,
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    childDirected: true,
    nonPersonalizedAds: true,
  );

  BannerAd _bannerAd;

  int count = 0;

  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: BannerAd.testAdUnitId,
      size: AdSize.banner,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("BannerAd event $event");
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseAdMob.instance.initialize(
        appId: Platform.isAndroid
            ? 'ca-app-pub-5426843524329045~3274164592'
            : 'ca-app-pub-5426843524329045~5102800320');
    _bannerAd = createBannerAd()..load();
    _bannerAd ??= createBannerAd();
    _bannerAd
      ..load()
      ..show(horizontalCenterOffset: 0, anchorOffset: 0);
    initPrefrence();

    if (Global.preferences.getBool(Global.HAS_GUIDE_KEY) == null ||
        !Global.preferences.getBool(Global.HAS_GUIDE_KEY)) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        show1();
      });
    }

    WidgetsBinding.instance.addObserver(this);

    NetworkUtil.isConnected().then((value) {
      if (value) {
        showDialog(
            context: context, builder: (context) => LoadingDialog("正在获取权限..."));
        NetworkUtil.doLogin(() {
          Navigator.pop(context);
          getSumCount();
        });
      }
    });
  }

  void initPrefrence() async {
    Global.preferences = await SharedPreferences.getInstance();
  }

  void getSumCount() async {
    await NetworkUtil.get("/api/counter", true, (respone) {
      CounterResponeBean counterResponeBean = CounterResponeBean.fromJson(
          jsonDecode(Utf8Decoder().convert(respone.bodyBytes)));
      AnimationController animationController =
          AnimationController(vsync: this, duration: Duration(seconds: 2));
      Animation<int> animation =
          IntTween(begin: 0, end: counterResponeBean.result)
              .animate(animationController);
      animationController.addListener(() {
        setState(() {
          count = animation.value;
        });
        if (animation.status == AnimationStatus.completed) {
          animationController.dispose();
        }
      });
      animationController.forward();
    }, (erro) {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive: // 处于这种状态的应用程序应该假设它们可能在任何时候暂停。
        print('这个是状态11111111');
        break;
      case AppLifecycleState.resumed: // 应用程序可见，前台
        print('这个是状态222222>>>>...前台');
        getSumCount();
        break;
      case AppLifecycleState.paused: // 应用程序不可见，后台
        print('这个是状态33333>>>>...后台');
        break;
      case AppLifecycleState.detached:
        print('这个是状态44444>>>>...好像是断网了');
        break;
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _bannerAd?.dispose();
    Global.timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Text(""),
            ),
            Container(
              child: Text(
                "全民格價",
                style: TextStyle(color: Colors.black, fontSize: 34),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 30),
              child: Text(
                "合理化的自由市場",
                style: TextStyle(color: Colors.black, fontSize: 17),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 30),
              child: Text(
                "已經收集了 " + count.toString() + " 張收據",
                style: TextStyle(color: Color(0xff666666), fontSize: 17),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(""),
            ),
            Container(
              width: 200,
              height: 70,
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(35),
                ),
                onPressed: () {
                  Navigator.push(context,
                      CupertinoPageRoute(builder: (context) => SearchPage()));
                },
                color: Color(0xff568AFF),
                child: Row(
                  children: <Widget>[
                    Container(
                        margin: EdgeInsets.only(left: 10),
                        child: Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 45,
                        )),
                    Container(
                      margin: EdgeInsets.only(left: 8),
                      child: Text(
                        "商品格價",
                        style: TextStyle(color: Colors.white, fontSize: 21),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Container(
              width: 200,
              height: 70,
              margin: EdgeInsets.only(top: 15),
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(35),
                ),
                onPressed: () {
                  takePhoto();
                },
                color: Color(0xffF4B400),
                child: Row(
                  children: <Widget>[
                    Container(
                        margin: EdgeInsets.only(left: 10),
                        child: Icon(
                          Icons.crop_free,
                          color: Colors.white,
                          size: 45,
                        )),
                    Container(
                      margin: EdgeInsets.only(left: 8),
                      child: Text(
                        "收據拍照",
                        style: TextStyle(color: Colors.white, fontSize: 21),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 107),
              child: FlatButton(
                child: Text(
                  "意見回饋",
                  style: TextStyle(color: Color(0xff4A4A4A), fontSize: 14),
                ),
                onPressed: () => Navigator.push(context,
                    CupertinoPageRoute(builder: (context) => AdvisePage())),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(""),
            ),
          ],
        ),
      ),
    );
  }

  void takePhoto() async {
    File val = await showDialog(
        context: context,
        builder: (context) => Camera(
              imageMask: CameraFocus.rectangle(
                color: Colors.black.withOpacity(0.5),
              ),
            ));

    if (val != null) {
      Navigator.push(
          context, CupertinoPageRoute(builder: (context) => UploadPage(val)));
    }
  }

  randomTestData() {
    List<CurvePoint> curvePointList = [];

    ///创建指引
    CurvePoint curvePoint = CurvePoint(0, 0);
    curvePoint.x = double.parse("0.5");
    curvePoint.y = double.parse(
        (0.5 + (3 / MediaQuery.of(context).size.height)).toString());
    curvePoint.tipsMessage = "点击这里进入搜索商品价格页面！";
    curvePoint.nextString = "下一步";
    curvePointList.add(curvePoint);

    CurvePoint curvePoint1 = CurvePoint(0, 0);
    curvePoint1.x = double.parse("0.5");
    curvePoint1.y = double.parse(
        (0.5 + (87 / MediaQuery.of(context).size.height)).toString());
    curvePoint1.tipsMessage = "点击这里进入搜索商品价格页面！";
    curvePoint1.nextString = "完成";
    curvePointList.add(curvePoint1);
    return curvePointList;
  }

  void show1() {
    ///获取模拟数据
    List<CurvePoint> curvePointList = randomTestData();
    showBeginnerGuidance(context,
        curvePointList: curvePointList,
        pointX: 0,
        pointY: 0,
        isSlide: true,
        logs: true,
        nextBackgroundColor: Color(0xff568AFF), clickCallback: (isEnd) {
      if (isEnd) {
        Global.preferences.setBool(Global.HAS_GUIDE_KEY, true);
      }
    });
  }
}
