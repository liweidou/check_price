import 'dart:io';

import 'package:check_price/customWidgets/Camera.dart';
import 'package:check_price/customWidgets/CameraFocus.dart';
import 'package:check_price/pages/SearchPage.dart';
import 'package:check_price/pages/UploadPage.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_guidance_plugin/flutter_guidance_plugin.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

const String testDevice = '33BE2250B43518CCDA7DE426D04EE232';

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    testDevices: testDevice != null ? <String>[testDevice] : null,
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    childDirected: true,
    nonPersonalizedAds: true,
  );

  BannerAd _bannerAd;

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

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      show1();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _bannerAd?.dispose();
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
              mode: CameraMode.fullscreen,
              orientationEnablePhoto: CameraOrientation.portrait,
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
        (0.5 + (110 / MediaQuery.of(context).size.height)).toString());
    curvePoint.tipsMessage = "点击这里进入搜索商品价格页面！";
    curvePoint.nextString = "下一步";
    curvePointList.add(curvePoint);

    CurvePoint curvePoint1 = CurvePoint(0, 0);
    curvePoint1.x = double.parse("0.5");
    curvePoint1.y = double.parse(
        (0.5 + (195 / MediaQuery.of(context).size.height)).toString());
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
        nextBackgroundColor: Color(0xff568AFF));
  }
}
