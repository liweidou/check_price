import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadPage extends StatefulWidget {
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  List<File> fileList = List();
  int getImagePos = 0;

  Future getImage(ImageSource imageSource) async {
    var image = await ImagePicker.pickImage(source: imageSource);
    setState(() {
      if (image != null) {
        fileList.add(image);
      }
      print(image.path);
    });
    if (getImagePos == 1) {
      getImage(ImageSource.camera);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: Text("上傳單據"),
        actions: <Widget>[
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.file_upload,
              color: Colors.blue,
            ),
          )
        ],
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
                childAspectRatio: 1.0,
                //子Widget列表
                children: getWidgetList(),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 50,bottom: 110),
              child: FloatingActionButton(
                onPressed: () {
                  showSelectImageDialog();
                },
                backgroundColor: Color(0xff003153),
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 34,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void showSelectImageDialog() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(
          '更多操作',
          style: TextStyle(fontSize: 22),
        ), //标题
        actions: <Widget>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              getImagePos = 0;
              getImage(ImageSource.camera);
            },
            child: Text(
              '相機(短單據)',
              style: TextStyle(color: Color(0xff007AFF), fontSize: 20),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              getImagePos = 1;
              getImage(ImageSource.camera);
            },
            child: Text(
              '相機(長單據)',
              style: TextStyle(color: Color(0xff007AFF), fontSize: 20),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              getImagePos = 2;
              getImage(ImageSource.gallery);
            },
            child: Text(
              '相册',
              style: TextStyle(color: Color(0xff007AFF), fontSize: 20),
            ),
          )
        ],
        cancelButton: CupertinoActionSheetAction(
          //取消按钮
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            '取消',
            style: TextStyle(color: Color(0xff007AFF), fontSize: 20),
          ),
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
            child: Image.file(
              item,
              fit: BoxFit.fill,
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
            ),
          )
        ],
      ),
    );
  }
}
