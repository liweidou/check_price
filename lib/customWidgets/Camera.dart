import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camera_camera/shared/widgets/orientation_icon.dart';
import 'package:camera_camera/shared/widgets/rotate_icon.dart';
import 'package:check_price/customWidgets/FocusRectangle.dart';
import 'package:check_price/customWidgets/bloc_camera.dart';
import 'package:check_price/customWidgets/scanner_utils.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:flutter_native_image/flutter_native_image.dart';

enum CameraOrientation { landscape, portrait, all }
enum CameraMode { fullscreen, normal }

class Camera extends StatefulWidget {
  final FocusRectangle imageMask;
  final CameraMode mode;
  final Widget warning;
  final CameraOrientation orientationEnablePhoto;
  final Function(File image) onFile;

  const Camera(
      {Key key,
      this.imageMask,
      this.mode = CameraMode.fullscreen,
      this.orientationEnablePhoto = CameraOrientation.all,
      this.onFile,
      this.warning})
      : super(key: key);

  @override
  _CameraState createState() => _CameraState();
}

class _CameraState extends State<Camera> with WidgetsBindingObserver {
  var bloc = BlocCamera();
  var previewH;
  var previewW;
  var screenRatio;
  var previewRatio;
  Size tmp;
  Size sizeImage;
  bool isRight = false;

  List<ImageLabel> labels;
  bool _isDetecting = false;
  CameraLensDirection _direction = CameraLensDirection.back;

  final ImageLabeler _imageLabeler = FirebaseVision.instance.imageLabeler();

  @override
  void initState() {
    super.initState();
    bloc.getCameras((data) {
      bloc.controllCamera = CameraController(
        data[0],
        ResolutionPreset.high,
      );
      bloc.cameraOn.sink.add(0);
      bloc.controllCamera.initialize().then((_) {
        bloc.selectCamera.sink.add(true);
        initMlKit();
      });
    });
    SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
  }

  void initMlKit() async {
    print("initMlKit:");
    if (bloc.controllCamera == null) print("bloc.controllCamera == null");
    bloc.controllCamera.startImageStream((CameraImage image) async {
      if (_isDetecting) return;
      _isDetecting = true;
      CameraDescription description = await ScannerUtils.getCamera(_direction);
      ScannerUtils.detect(
        image: image,
        detectInImage: _imageLabeler.processImage,
        imageRotation: description.sensorOrientation,
      ).then(
        (dynamic results) {
          setState(() {
            labels = results;
            bool ir = false;
            for (ImageLabel label in labels) {
              if (label.text == "Receipt" ||
                  label.text == "Paper" ||
                  label.text == "receipt") {
                ir = true;
              }
              print("label.text:" + label.text);
            }
            isRight = ir;
            print("isright:" + isRight.toString());
          });
        },
      ).whenComplete(() => _isDetecting = false);
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    bloc.controllCamera.dispose().then((_) {
      _imageLabeler.close();
    });
    super.dispose();
    bloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;

    return NativeDeviceOrientationReader(
      useSensor: true,
      builder: (context) {
        NativeDeviceOrientation orientation =
            NativeDeviceOrientationReader.orientation(context);

        _buttonPhoto() => Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                  border: Border.all(
                      color: isRight ? Colors.green : Colors.red,
                      width: 2,
                      style: BorderStyle.solid)),
              child: IconButton(
                icon: Icon(
                  CupertinoIcons.circle_filled,
                  color: Colors.white,
                  size: 80,
                ),
                onPressed: () {
                  if (isRight) {
                    sizeImage = MediaQuery.of(context).size;
                    bloc.onTakePictureButtonPressed();
                    bloc.onTakePictureButtonPressed();
                  } else {
                    Fluttertoast.showToast(msg: "請拍收據");
                  }
                },
              ),
            );

        Widget _getButtonPhoto() {
          if (widget.orientationEnablePhoto == CameraOrientation.all) {
            return _buttonPhoto();
          } else if (widget.orientationEnablePhoto ==
              CameraOrientation.landscape) {
            if (orientation == NativeDeviceOrientation.landscapeLeft ||
                orientation == NativeDeviceOrientation.landscapeRight)
              return _buttonPhoto();
            else
              return Container(
                width: 0.0,
                height: 0.0,
              );
          } else {
            if (orientation == NativeDeviceOrientation.portraitDown ||
                orientation == NativeDeviceOrientation.portraitUp)
              return _buttonPhoto();
            else
              return Container(
                width: 0.0,
                height: 0.0,
              );
          }
        }

        if (orientation == NativeDeviceOrientation.portraitDown ||
            orientation == NativeDeviceOrientation.portraitUp) {
          sizeImage = Size(width, height);
        } else {
          sizeImage = Size(height, width);
        }

        return Scaffold(
          backgroundColor: Colors.black,
          body: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width,
              maxHeight: MediaQuery.of(context).size.height,
            ),
            child: Stack(
              children: <Widget>[
                Center(
                  child: StreamBuilder<File>(
                      stream: bloc.imagePath.stream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Stack(
                            children: <Widget>[
                              OverflowBox(
                                maxHeight: size.height,
                                maxWidth: size.height * previewRatio,
                                child: Image.file(snapshot.data),
                              ),
                            ],
                          );
                        } else {
                          return Stack(
                            children: <Widget>[
                              Center(
                                child: StreamBuilder<bool>(
                                    stream: bloc.selectCamera.stream,
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        if (snapshot.data) {
                                          previewRatio = bloc
                                              .controllCamera.value.aspectRatio;

                                          return widget.mode ==
                                                  CameraMode.fullscreen
                                              ? OverflowBox(
                                                  maxHeight: size.height,
                                                  maxWidth: size.height *
                                                      previewRatio,
                                                  child: CameraPreview(
                                                      bloc.controllCamera),
                                                )
                                              : AspectRatio(
                                                  aspectRatio: bloc
                                                      .controllCamera
                                                      .value
                                                      .aspectRatio,
                                                  child: CameraPreview(
                                                      bloc.controllCamera),
                                                );
                                        } else {
                                          return Container();
                                        }
                                      } else {
                                        return Container();
                                      }
                                    }),
                              ),
                              if (widget.imageMask != null)
                                Center(
                                  child: widget.imageMask,
                                ),
                            ],
                          );
                        }
                      }),
                ),
                if (widget.mode == CameraMode.fullscreen)
                  Container(
                    margin: EdgeInsets.only(top: height - height / 3),
                    child: StreamBuilder<Object>(
                        stream: bloc.imagePath.stream,
                        builder: (context, snapshot) {
                          return snapshot.hasData
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    CircleAvatar(
                                      child: IconButton(
                                        icon: OrientationWidget(
                                          orientation: orientation,
                                          child: Icon(Icons.close,
                                              color: Colors.white),
                                        ),
                                        onPressed: () {
                                          bloc.deletePhoto(() => initMlKit());
                                        },
                                      ),
                                      backgroundColor: Colors.black38,
                                      radius: 25.0,
                                    ),
                                    CircleAvatar(
                                      child: IconButton(
                                        icon: OrientationWidget(
                                          orientation: orientation,
                                          child: Icon(Icons.check,
                                              color: Colors.white),
                                        ),
                                        onPressed: () async {
                                          File compressedFile =
                                              await FlutterNativeImage
                                                  .compressImage(
                                                      bloc.imagePath.value.path,
                                                      quality: 100,
                                                      targetWidth:
                                                          width.toInt(),
                                                      targetHeight:
                                                          height.toInt());
                                          File croppedFile =
                                              await FlutterNativeImage
                                                  .cropImage(
                                                      compressedFile.path,
                                                      (width / 16).toInt(),
                                                      (height / 24).toInt(),
                                                      (width - width / 16)
                                                          .toInt(),
                                                      (height - height / 3.5)
                                                          .toInt());
                                          if (widget.onFile == null)
                                            Navigator.pop(context, croppedFile);
                                          else {
                                            widget.onFile(croppedFile);
                                          }
                                        },
                                      ),
                                      backgroundColor: Colors.black38,
                                      radius: 25.0,
                                    )
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    CircleAvatar(
                                      child: Text(""),
                                      backgroundColor: Colors.transparent,
                                      radius: 25.0,
                                    ),
                                    Container(
                                      child: IconButton(
                                        color: Colors.white,
                                        icon: Icon(
                                          Icons.cancel,
                                          size: 30,
                                        ),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                      height: 80,
                                    ),
                                    Container(
                                      width: 72,
                                      height: 72,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: isRight
                                                  ? Colors.green
                                                  : Colors.red,
                                              width: 2,
                                              style: BorderStyle.solid),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(37))),
                                      child: Align(
                                        alignment: FractionalOffset(0.08, -0.5),
                                        child: IconButton(
                                          icon: Icon(
                                            CupertinoIcons.circle_filled,
                                            color: Colors.white,
                                            size: 80,
                                          ),
                                          onPressed: () {
                                            if(isRight) {
                                              sizeImage = MediaQuery
                                                  .of(context)
                                                  .size;
                                              bloc.onTakePictureButtonPressed();
                                              bloc.onTakePictureButtonPressed();
                                            }else{
                                              Fluttertoast.showToast(msg: "請拍收據");
                                            }
                                          },
                                          padding: EdgeInsets.all(0),
                                        ),
                                      ),
                                    ),
                                    CircleAvatar(
                                      child: Text(""),
                                      backgroundColor: Colors.transparent,
                                      radius: 25.0,
                                    ),
                                    CircleAvatar(
                                      child: Text(""),
                                      backgroundColor: Colors.transparent,
                                      radius: 25.0,
                                    )
                                  ],
                                );
                        }),
                  )
              ],
            ),
          ),
          bottomNavigationBar: widget.mode == CameraMode.normal
              ? BottomAppBar(
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20.0, top: 10.0),
                    child: StreamBuilder<Object>(
                        stream: bloc.imagePath.stream,
                        builder: (context, snapshot) {
                          return snapshot.hasData
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    CircleAvatar(
                                      child: IconButton(
                                        icon: OrientationWidget(
                                          orientation: orientation,
                                          child: Icon(Icons.close,
                                              color: Colors.white),
                                        ),
                                        onPressed: () {
                                          bloc.deletePhoto(() => initMlKit());
                                        },
                                      ),
                                      backgroundColor: Colors.black38,
                                      radius: 25.0,
                                    ),
                                    CircleAvatar(
                                      child: IconButton(
                                        icon: OrientationWidget(
                                          orientation: orientation,
                                          child: Icon(Icons.check,
                                              color: Colors.white),
                                        ),
                                        onPressed: () {
                                          if (widget.onFile == null)
                                            Navigator.pop(
                                                context, bloc.imagePath.value);
                                          else {
                                            widget.onFile(bloc.imagePath.value);
                                          }
                                        },
                                      ),
                                      backgroundColor: Colors.black38,
                                      radius: 25.0,
                                    )
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    CircleAvatar(
                                      child: IconButton(
                                        icon: OrientationWidget(
                                          orientation: orientation,
                                          child: Icon(Icons.arrow_back_ios,
                                              color: Colors.white),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                      backgroundColor: Colors.black38,
                                      radius: 25.0,
                                    ),
                                    _getButtonPhoto(),
                                    CircleAvatar(
                                      child: RotateIcon(
                                        child: OrientationWidget(
                                          orientation: orientation,
                                          child: Icon(
                                            Icons.cached,
                                            color: Colors.white,
                                          ),
                                        ),
                                        onTap: () {
                                          bloc.changeCamera();
                                        },
                                      ),
                                      backgroundColor: Colors.black38,
                                      radius: 25.0,
                                    )
                                  ],
                                );
                        }),
                  ),
                )
              : Container(
                  width: 0.0,
                  height: 0.0,
                ),
        );
      },
    );
  }
}
