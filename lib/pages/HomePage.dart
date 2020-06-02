import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:check_price/beans/CounterResponeBean.dart';
import 'package:check_price/beans/UploadPermissionResponeBean.dart';
import 'package:check_price/customWidgets/Camera.dart';
import 'package:check_price/customWidgets/FocusRectangle.dart';
import 'package:check_price/customWidgets/LoadingDialog.dart';
import 'package:check_price/pages/AdvisePage.dart';
import 'package:check_price/pages/SearchPage.dart';
import 'package:check_price/pages/ThanksPage.dart';
import 'package:check_price/utils/CommonUtils.dart';
import 'package:check_price/utils/Global.dart';
import 'package:check_price/utils/NetworkUtil.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_guidance_plugin/flutter_guidance_plugin.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:imei_plugin/imei_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

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

  FirebaseStorage storage;

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

  void initFireBase() async {
    final FirebaseApp app = await FirebaseApp.configure(
      name: 'test',
      options: FirebaseOptions(
        googleAppID: (Platform.isIOS || Platform.isMacOS)
            ? '1:336897268673:ios:7fa150b8347f588bafed40'
            : '1:336897268673:android:715255b687b9ef5bafed40',
        gcmSenderID: '336897268673',
        apiKey: 'AIzaSyC3tNQN4KPOr3rD2annr2a_iagwOPR7kQw',
        projectID: 'pricetags-277703',
      ),
    );
    storage = FirebaseStorage(
        app: app, storageBucket: 'gs://pricetags-277703.appspot.com');
  }

  Future<void> _uploadFiles(File imageFile) async {
    NetworkUtil.isConnected().then((value) async {
      if (value) {
        showDialog(
            context: context, builder: (context) => LoadingDialog("正在上傳收據..."));
        String platformImei = await ImeiPlugin.getImei(
            shouldShowRequestPermissionRationale: false);
        var params = {
          "deviceime": platformImei,
        };
        var body = utf8.encode(json.encode(params));
        await NetworkUtil.postWithBody("/api/device/permission", body, true,
                (respone) async {
              UploadPermissionResponeBean uploadPermissionResponeBean =
              UploadPermissionResponeBean.fromJson(
                  jsonDecode(Utf8Decoder().convert(respone.bodyBytes)));
              if (uploadPermissionResponeBean.code == 200 &&
                  uploadPermissionResponeBean.result.permission) {
                String uuid = Uuid().v1();
                final StorageReference ref =
                storage.ref().child('public').child('$uuid.jpg');
                final StorageUploadTask uploadTask = ref.putFile(imageFile);
                StreamSubscription<StorageTaskEvent> streamSubscription;
                streamSubscription = uploadTask.events.listen((event) async{
                  print('EVENT ${event.type}');
                  if (uploadTask.isComplete) {
                    if (uploadTask.isSuccessful) {

                    } else if (uploadTask.isCanceled) {

                    } else {//失敗
                      CommonUtils.showToast(context, "錯誤碼:" + uploadTask.lastSnapshot.error.toString());
                      await NetworkUtil.sentry.captureException(
                        exception: uploadTask.lastSnapshot.error,
                        stackTrace: uploadTask.lastSnapshot.error,
                      );
                    }

                    streamSubscription.cancel();
                    await NetworkUtil.post("/api/counter", true, (respone) {
                      Navigator.pop(context);
                      Navigator.push(context,
                          CupertinoPageRoute(builder: (context) => ThanksPage()));
                    }, (erro) {
                      CommonUtils.showToast(context, "上傳失敗，請提意見給我們！");
                    });
                  }
                });
              } else {
                CommonUtils.showToast(context, "請提意見給我們！");
              }
            }, (erro) {
              Navigator.pop(context);
              Fluttertoast.showToast(msg: erro);
            });
      } else {
        CommonUtils.showToast(context, "請檢查網絡！");
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseAdMob.instance.initialize(
        appId: Platform.isAndroid
            ? 'ca-app-pub-5426843524329045~3274164592'
            : 'ca-app-pub-5426843524329045~5102800320');
    _bannerAd = createBannerAd()
      ..load();
    _bannerAd ??= createBannerAd();
    _bannerAd
      ..load()
      ..show(horizontalCenterOffset: 0, anchorOffset: 0);
    initPrefrence();

    WidgetsBinding.instance.addObserver(this);

    initFireBase();
  }

  randomTestData() {
    List<CurvePoint> curvePointList = [];

    ///创建指引
    CurvePoint curvePoint = CurvePoint(0, 0);
    curvePoint.x = double.parse("0.5");
    curvePoint.y = double.parse(
        (0.5 + (3 / MediaQuery
            .of(context)
            .size
            .height)).toString());
    curvePoint.tipsMessage = "点击这里进入搜索商品价格页面！";
    curvePoint.nextString = "下一步";
    curvePointList.add(curvePoint);

    CurvePoint curvePoint1 = CurvePoint(0, 0);
    curvePoint1.x = double.parse("0.5");
    curvePoint1.y = double.parse(
        (0.5 + (87 / MediaQuery
            .of(context)
            .size
            .height)).toString());
    curvePoint1.tipsMessage = "点击这里进入搜索商品价格页面！";
    curvePoint1.nextString = "完成";
    curvePointList.add(curvePoint1);
    return curvePointList;
  }

  void initPrefrence() async {
    Global.preferences = await SharedPreferences.getInstance();
    NetworkUtil.isConnected().then((value) {
      if (value) {
        showDialog(
            context: context, builder: (context) => LoadingDialog("正在获取权限..."));
        NetworkUtil.doLogin(context, () {
          Navigator.pop(context);
          if (Global.preferences.getBool(Global.HAS_GUIDE_KEY) == null ||
              !Global.preferences.getBool(Global.HAS_GUIDE_KEY)) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              List<CurvePoint> curvePointList = randomTestData();
              showBeginnerGuidance(context,
                  curvePointList: curvePointList,
                  pointX: 0,
                  pointY: 0,
                  isSlide: true,
                  logs: true,
                  nextBackgroundColor: Color(0xff568AFF),
                  clickCallback: (isEnd) {
                    if (isEnd) {
                      Global.preferences.setBool(Global.HAS_GUIDE_KEY, true);
                    }
                  });
            });
          }
          getSumCount();
        });
      }
    });
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
                onPressed: () =>
                    Navigator.push(context,
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
        builder: (context) =>
            Camera(
              imageMask: FocusRectangle(
                color: Colors.black.withOpacity(0),
              ),
            ));

    if (val != null) {
      if (Global.preferences.getBool(Global.AGREE_USE_KEY) ==
          null ||
          !Global.preferences.getBool(Global.AGREE_USE_KEY)) {
        showCupertinoDialog(
            context: context,
            builder: (context) {
              return new CupertinoAlertDialog(
                title: new Text("使用條款"),
                content: new Text("内容内容内容内容内容内容内容内容内容内容内容"),
                actions: <Widget>[
                  new FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: new Text(
                      "取消",
                      style: TextStyle(color: Color(0xff007AFF)),
                    ),
                  ),
                  new FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Global.preferences
                          .setBool(Global.AGREE_USE_KEY, true);
                      _uploadFiles(val);
                    },
                    child: new Text("同意並上傳",
                        style: TextStyle(color: Color(0xff007AFF))),
                  ),
                ],
              );
            });
      }else{
        _uploadFiles(val);
      }
    }
  }
}
