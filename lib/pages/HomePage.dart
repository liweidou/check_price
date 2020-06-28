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
import 'package:imei_plugin/imei_plugin.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../utils/NetworkUtil.dart';

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

  GlobalKey searchKey = GlobalKey();
  GlobalKey photoKey = GlobalKey();

  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: (Platform.isIOS || Platform.isMacOS)
          ? "ca-app-pub-5426843524329045/3629387819"
          : "ca-app-pub-5426843524329045/3281903454",
      size: AdSize.banner,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("BannerAd event $event");
      },
    );
  }

  void initFireBase() async {
    final FirebaseApp app = await FirebaseApp.configure(
      name: '全民格價',
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
    FirebaseAdMob.instance.initialize(
        appId: Platform.isAndroid
            ? 'ca-app-pub-5426843524329045~3274164592'
            : 'ca-app-pub-5426843524329045~5102800320');
    initAndShowBanner();
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
            streamSubscription = uploadTask.events.listen((event) async {
              print('EVENT ${event.type}');
              if (uploadTask.isComplete) {
                if (uploadTask.isSuccessful) {
                  await NetworkUtil.post("/api/counter", true, (respone) {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => ThanksPage())).then((value) {
                      getSumCount();
                    });
                  }, (erro) {
                    CommonUtils.showToast(context, "上傳失敗，請提意見給我們！");
                  });
                } else if (uploadTask.isCanceled) {
                  Navigator.pop(context);
                } else {
                  //失敗
                  Navigator.pop(context);
                  CommonUtils.showToast(context,
                      "錯誤碼:" + uploadTask.lastSnapshot.error.toString());
                  await NetworkUtil.sentry.captureException(
                    exception: uploadTask.lastSnapshot.error,
                    stackTrace: uploadTask.lastSnapshot.error,
                  );
                  CommonUtils.showToast(context, "上傳失敗，請提意見給我們！");
                }

                streamSubscription.cancel();
              }
            });
          } else {
            CommonUtils.showToast(context, "請提意見給我們！");
          }
        }, (erro) {
          Navigator.pop(context);
          if (erro.statusCode == 401) {
            NetworkUtil.doLogin(() {
              _uploadFiles(imageFile);
            });
          } else if (erro.statusCode == 400) {
            Global.preferences.setString(Global.REFRESH_TOKEN_KEY, "");
            NetworkUtil.doLogin(() {
              NetworkUtil.registerDevice(context, () {
                _uploadFiles(imageFile);
              });
            });
          } else {
            CommonUtils.showToast(context, "您沒有上傳權限，請提意見給我們！");
            NetworkUtil.registerDevice(context, () {});
          }
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

    initPrefrence();

    WidgetsBinding.instance.addObserver(this);

    initFireBase();
  }

  void initAndShowBanner() {
    if (_bannerAd == null) {
      _bannerAd ??= createBannerAd();
      _bannerAd
        ..load()
        ..show(horizontalCenterOffset: 0, anchorOffset: 0);
    }
  }

  void hideBanner() {
    if (_bannerAd != null) {
      _bannerAd.dispose();
      _bannerAd = null;
    }
  }

  randomTestData() {
    List<CurvePoint> curvePointList = [];

    ///创建指引
    RenderBox sbox = searchKey.currentContext.findRenderObject();
    Offset soffset = sbox.localToGlobal(Offset.zero);
    CurvePoint curvePoint = CurvePoint(0, 0);
    curvePoint.x = double.parse("0.5");
//    curvePoint.y = double.parse(
//        (0.5 + (3 / MediaQuery.of(context).size.height)).toString());
    curvePoint.y = (soffset.dy + 20) / MediaQuery.of(context).size.height;
    curvePoint.tipsMessage = "點擊這裡進入搜索商品價格頁面！";
    curvePoint.nextString = "下一步";
    curvePointList.add(curvePoint);

    print("x:" + soffset.dx.toString() + " y:" + soffset.dy.toString());
    print("x:" + soffset.dx.toString() + " y:" + soffset.dy.toString());

    RenderBox pbox = photoKey.currentContext.findRenderObject();
    Offset poffset = pbox.localToGlobal(Offset.zero);
    CurvePoint curvePoint1 = CurvePoint(0, 0);
    curvePoint1.x = double.parse("0.5");
//    curvePoint1.y = double.parse(
//        (0.5 + (87 / MediaQuery.of(context).size.height)).toString());
    curvePoint1.y = (poffset.dy + 40) / MediaQuery.of(context).size.height;
    curvePoint1.tipsMessage = "點擊這裡進入拍攝收據頁面！";
    curvePoint1.nextString = "完成";
    curvePointList.add(curvePoint1);
    return curvePointList;
  }

  void initPrefrence() async {
    Global.preferences = await SharedPreferences.getInstance();
    Global.API_TOKEN = Global.preferences.getString(Global.REFRESH_TOKEN_KEY);
    NetworkUtil.isConnected().then((value) {
      if (value) {
        showDialog(
            context: context, builder: (context) => LoadingDialog("初始化中..."));
        NetworkUtil.doLogin(() {
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
          NetworkUtil.registerDevice(context, () {});
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
    }, (erro) {
      if (erro.statusCode == 401) {
        NetworkUtil.doLogin(() {
          getSumCount();
        });
      } else if (erro.statusCode == 400) {
        Global.preferences.setString(Global.REFRESH_TOKEN_KEY, "");
        NetworkUtil.doLogin(() {
          getSumCount();
        });
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive: // 处于这种状态的应用程序应该假设它们可能在任何时候暂停。
        print('这个是状态11111111');
        break;
      case AppLifecycleState.resumed: // 应用程序可见，前台
        print('这个是状态222222>>>>...前台');
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
      body: SafeArea(
        top: true,
        child: Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                alignment: Alignment.topRight,
                margin: EdgeInsets.only(top: 20, right: 8),
                child: FlatButton(
                  onPressed: () {
                    Share.share(Platform.isAndroid
                        ? "https://play.google.com/store/apps/details?id=com.infitack.check_price"
                        : "https://apps.apple.com/app/id1515103936");
                  },
                  child: Text(
                    "介紹給朋友",
                    style: TextStyle(color: Color(0xff4a4a4a), fontSize: 14),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(""),
              ),
              Hero(
                tag: "title",
                child: FlatButton(
                  child: Text(
                    "全民格價",
                    style: TextStyle(color: Colors.black, fontSize: 34),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 20),
                child: Text(
                  "全民應用科技",
                  style: TextStyle(color: Colors.black, fontSize: 17),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10),
                child: Text(
                  "齊齊慳錢",
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
                key: searchKey,
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
                key: photoKey,
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
                margin: EdgeInsets.only(top: 70),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Text(""),
                    ),
                    FlatButton(
                      child: Text(
                        "官方網站",
                        style:
                            TextStyle(color: Color(0xff4A4A4A), fontSize: 14),
                      ),
                      onPressed: () async {
//                        LaunchReview.launch(
//                            androidAppId: "com.infitack.check_price",
//                            iOSAppId: "666666");
                        await launch("http://pricetag.morephil.com/");
                      },
                    ),
                    Container(
                      width: 14,
                      height: 20,
                      alignment: Alignment.center,
                      child: Text("|"),
                    ),
                    FlatButton(
                      child: Text(
                        "意見回饋",
                        style:
                            TextStyle(color: Color(0xff4A4A4A), fontSize: 14),
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => AdvisePage()));
                      },
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(""),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(""),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void takePhoto() async {
    hideBanner();
    File val = await showDialog(
        context: context,
        builder: (context) => Camera(
              imageMask: FocusRectangle(
                color: Colors.black.withOpacity(0),
              ),
            ));
    initAndShowBanner();
    if (val != null) {
      if (Global.preferences.getBool(Global.AGREE_USE_KEY) == null ||
          !Global.preferences.getBool(Global.AGREE_USE_KEY)) {
        showCupertinoDialog(
            context: context,
            builder: (context) {
              return new CupertinoAlertDialog(
                title: new Text("使用條款"),
                content: new Text(
                    "「全民格價」是由「morephil.com」（下稱我們）所經營之APP(下稱本APP)各項服務與資訊。 "
                    "以下是我們的隱私權保護政策，幫助您瞭解本APP所蒐集的個人資料之運用及保護方式。 一、隱私權保護政策的適用範圍     "
                    "（1）請您在於使用本APP服務前，確認您已審閱並同意本隱私權政策所列全部條款，若您不同意全部或部份者，則請勿使用本APP服務。"
                    "     （2）隱私權保護政策內容，包括我們如何處理您在使用本APP服務時蒐集到的個人識別資料。   "
                    "  （3）隱私權保護政策不適用於本APP以外的相關連結網站，亦不適用於非我們所委託或參與管理之人員。"
                    " 二、個人資料的蒐集及使用    "
                    " （1）本APP並不會蒐集任何有關個人的身份資料。 三、對外的相關連結 本APP上有可能包含其他合作網站或網頁連結，"
                    "該網站或網頁也有可能會蒐集您的個人資料，不論其內容或隱私權政策為何，皆與本APP 無關，"
                    "您應自行參考該連結網站中的隱私權保護政策，我們不負任何連帶責任。四、Cookie之使用     "
                    "（1）為了提供您最佳的服務，本網站會在您的電腦中放置並取用我們的Cookie，若您不願接受Cookie的寫入，"
                    "您可在您使用的瀏覽器功能項中設定隱私權等級為高，即可拒絕Cookie的寫入，但可能會導致網站某些功能無法正常執行 。 "
                    "以下是可能使用的Cookie範例:         •session cookies. 用來維護應用程式的狀態         •Preference Cookies."
                    " 用來記錄您的喜好與設定         •Security Cookies. 用來控制安全和檢查 "
                    "五、未成年人保護 未成年人於註冊或使用本服務而同意本公司蒐集、利用其個人資訊時，應按其年齡由其法定代理人代為或在法定代理人之同意下為之。"
                    "六、隱私權政策的修訂 我們將因應需求擁有隨時修改本隱私權保護政策的權利，當我們做出修改時，會於本APP公告，且自公告日起生效，不再另行通知。"),
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
                      Global.preferences.setBool(Global.AGREE_USE_KEY, true);
                      _uploadFiles(val);
                    },
                    child: new Text("同意並上傳",
                        style: TextStyle(color: Color(0xff007AFF))),
                  ),
                ],
              );
            });
      } else {
        _uploadFiles(val);
      }
    }
  }
}
