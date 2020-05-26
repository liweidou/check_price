import 'dart:async';
import 'dart:io';

import 'package:check_price/customWidgets/Camera.dart';
import 'package:check_price/customWidgets/CameraFocus.dart';
import 'package:check_price/customWidgets/LoadingDialog.dart';
import 'package:check_price/pages/ThanksPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class UploadPage extends StatefulWidget {
  File firstFile;

  UploadPage(this.firstFile);

  @override
  _UploadPageState createState() => _UploadPageState(firstFile);
}

class _UploadPageState extends State<UploadPage> {
  List<File> fileList = List();
  int neekUploadFileSize = 0;
  FirebaseStorage storage;

  _UploadPageState(File firstFile) {
    fileList.add(firstFile);
  }

  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    initFireBase();
  }

  void initFireBase() async{
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
    showDialog(context: context,builder: (context)=> LoadingDialog("正在上傳收據..."));
    String uuid = Uuid().v1();
    for (int i = 0; i < fileList.length; i++) {
      final StorageReference ref =
          storage.ref().child('image').child('$uuid=image$i.jpg');
      final StorageUploadTask uploadTask = ref.putFile(fileList[i]);
      final StreamSubscription<StorageTaskEvent> streamSubscription = uploadTask.events.listen((event) {
             print('EVENT ${event.type}');
             if(uploadTask.isComplete){
               print('streamSubscription.uploadTask.isComplete');
             }
      });
      await uploadTask.onComplete;
      print('uploadTask.isComplete');
      neekUploadFileSize--;
      streamSubscription.cancel();
      if(neekUploadFileSize == 0){
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.push(
            context, CupertinoPageRoute(builder: (context) => ThanksPage()));
      }
    }
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
        title: Text(
          "照片",
          style: TextStyle(color: Colors.white),
        )
      ),
      body: Container(
        width: double.infinity,
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: GridView.count(
                //水平子Widget之间间距
                crossAxisSpacing: 10.0,
                //垂直子Widget之间间距
                mainAxisSpacing: 30.0,
                //GridView内边距
                padding: EdgeInsets.all(10.0),
                //一行的Widget数量
                crossAxisCount: 2,
                //子Widget宽高比例
                childAspectRatio: 0.666,
                //子Widget列表
                children: getWidgetList(),
              ),
            ),
            Container(
              width: 160,
              height: 70,
              margin: EdgeInsets.only(bottom: 15),
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
                        "繼續",
                        style: TextStyle(color: Colors.white, fontSize: 21),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Container(
              width: 160,
              height: 70,
              margin: EdgeInsets.only(bottom: 95),
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(35),
                ),
                onPressed: () {
                  if (fileList.length != 0) {
                    neekUploadFileSize = fileList.length;
                    _uploadFiles();
                  } else {}
                },
                color: Color(0xff0F9D58),
                child: Row(
                  children: <Widget>[
                    Container(
                        margin: EdgeInsets.only(left: 10),
                        child: Icon(
                          Icons.cloud_upload,
                          color: Colors.white,
                          size: 41,
                        )),
                    Container(
                      margin: EdgeInsets.only(left: 8),
                      child: Text(
                        "上傳",
                        style: TextStyle(color: Colors.white, fontSize: 21),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> getWidgetList() {
    return fileList.map((item) => getItemContainer(item)).toList();
  }

  Widget getItemContainer(File item) {
    return Container(
      child: Stack(
        children: <Widget>[
          Positioned(
            left: 0,
            right: 0,
            child: Container(
              child: Image.file(
                item,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            right: 0,
            child: IconButton(
              onPressed: () {
                setState(() {
                  fileList.remove(item);
                });
              },
              icon: Icon(Icons.cancel),
              color: Colors.black,
            ),
          )
        ],
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

    if (val == null) {
//      if (fileList.length == 0) Navigator.pop(context);
    } else {
      setState(() {
        fileList.add(val);
      });
    }
  }
}
