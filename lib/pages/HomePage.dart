import 'dart:io';

import 'package:check_price/pages/SearchPage.dart';
import 'package:check_price/pages/UploadPage.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

const String testDevice = '33BE2250B43518CCDA7DE426D04EE232';

class _HomePageState extends State<HomePage> {

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
    FirebaseAdMob.instance.initialize(appId: Platform.isAndroid
        ? 'ca-app-pub-5426843524329045~3274164592'
        : 'ca-app-pub-5426843524329045~5102800320');
    _bannerAd = createBannerAd()..load();
    _bannerAd ??= createBannerAd();
    _bannerAd
      ..load()
      ..show(horizontalCenterOffset: 0, anchorOffset: 0);
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
                "大家一起捍衛合理的自由市場",
                style: TextStyle(color: Colors.black, fontSize: 17),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(""),
            ),
            Container(
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Text(""),
                  ),
                  Container(
                    width: 120,
                    height: 120,
                    child: RaisedButton(
                      onPressed:  () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => UploadPage()));
                      },
                      color: Color(0xff003153),
                      child: Icon(
                        Icons.camera_enhance,
                        color: Colors.white,
                        size: 74,
                      ),
                    ),
                  ),
                  Container(
                    width: 120,
                    height: 120,
                    margin: EdgeInsets.only(left: 40),
                    child: RaisedButton(
                      onPressed:  () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => SearchPage()));
                      },
                      color: Color(0xff568AFF),
                      child: Icon(
                        Icons.search,
                        color: Colors.white,
                        size: 74,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(""),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(""),
            ),
          ],
        ),
      ),
    );
  }
}
