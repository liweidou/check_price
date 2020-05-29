import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:check_price/beans/UploadPermissionResponeBean.dart';
import 'package:check_price/customWidgets/Camera.dart';
import 'package:check_price/customWidgets/FocusRectangle.dart';
import 'package:check_price/customWidgets/LoadingDialog.dart';
import 'package:check_price/pages/ThanksPage.dart';
import 'package:check_price/utils/Global.dart';
import 'package:check_price/utils/NetworkUtil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:imei_plugin/imei_plugin.dart';
import 'package:uuid/uuid.dart';

class UploadPage extends StatefulWidget {
  File firstFile;

  UploadPage(this.firstFile);

  @override
  _UploadPageState createState() => _UploadPageState(firstFile);
}

class _UploadPageState extends State<UploadPage> {
  File imageFile;
  FirebaseStorage storage;

  _UploadPageState(File firstFile) {
    imageFile = firstFile;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initFireBase();
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

  Future<void> _uploadFiles() async {
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
            final StreamSubscription<StorageTaskEvent> streamSubscription =
                uploadTask.events.listen((event) {
              print('EVENT ${event.type}');
              if (uploadTask.isComplete) {
                print('streamSubscription.uploadTask.isComplete');
              }
            });
            await uploadTask.onComplete;
            print('uploadTask.isComplete');
            streamSubscription.cancel();
            await NetworkUtil.post("/api/counter", true, (respone) {
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.push(context,
                  CupertinoPageRoute(builder: (context) => ThanksPage()));
            }, (erro) {
              Fluttertoast.showToast(msg: "上傳失敗，請提意見給我們！");
            });
          } else {
            Fluttertoast.showToast(msg: "請提意見給我們！");
          }
        }, (erro) {
          Navigator.pop(context);
          Fluttertoast.showToast(msg: erro);
        });
      } else {
        Fluttertoast.showToast(msg: "請檢查網絡！");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Color(0xffF4B400),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                if (imageFile != null) {
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
                                  _uploadFiles();
                                },
                                child: new Text("同意並上傳",
                                    style: TextStyle(color: Color(0xff007AFF))),
                              ),
                            ],
                          );
                        });
                  } else {
                    _uploadFiles();
                  }
                } else {
                  Fluttertoast.showToast(msg: "請先拍照");
                }
              },
              child: Text(
                "上傳",
                style: TextStyle(color: Colors.white, fontSize: 17),
              ),
            )
          ],
          title: Text(
            "照片",
            style: TextStyle(color: Colors.white),
          )),
      body: Container(
        width: double.infinity,
        child: Stack(
          children: <Widget>[
            imageFile == null
                ? Text("")
                : Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height,
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                          left: 0,
                          right: 0,
                          child: Container(
                            child: Image.file(
                              imageFile,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                imageFile = null;
                              });
                            },
                            icon: Icon(Icons.cancel),
                            color: Colors.black,
                          ),
                        )
                      ],
                    ),
                  ),
            Container(
              width: 160,
              height: 70,
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height - 250,
                  left: MediaQuery.of(context).size.width / 2 - 80),
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
                          size: 41,
                        )),
                    Container(
                      margin: EdgeInsets.only(left: 8),
                      child: Text(
                        "重拍",
                        style: TextStyle(color: Colors.white, fontSize: 21),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void takePhoto() async {
    File val = await showDialog(
        context: context,
        builder: (context) => Camera(
              imageMask: FocusRectangle(
                color: Colors.black.withOpacity(0.5),
                isRight: false,
              ),
            ));

    if (val == null) {
//      if (fileList.length == 0) Navigator.pop(context);
    } else {
      setState(() {
        imageFile = val;
      });
    }
  }
}
