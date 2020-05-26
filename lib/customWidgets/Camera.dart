import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camera_camera/page/bloc/bloc_camera.dart';
import 'package:camera_camera/shared/widgets/orientation_icon.dart';
import 'package:camera_camera/shared/widgets/rotate_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
//import 'package:flutter_native_image/flutter_native_image.dart';

enum CameraOrientation { landscape, portrait, all }
enum CameraMode { fullscreen, normal }

class Camera extends StatefulWidget {
  final Widget imageMask;
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

class _CameraState extends State<Camera> {
  var bloc = BlocCamera();
  var previewH;
  var previewW;
  var screenRatio;
  var previewRatio;
  Size tmp;
  Size sizeImage;

  @override
  void initState() {
    super.initState();
    bloc.getCameras();
    bloc.cameras.listen((data) {
      bloc.controllCamera = CameraController(
        data[0],
        ResolutionPreset.high,
      );
      bloc.cameraOn.sink.add(0);
      bloc.controllCamera.initialize().then((_) {
        bloc.selectCamera.sink.add(true);
      });
    });
    SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
    bloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    Size sizeImage = size;
    double width = size.width;
    double height = size.height;

    return NativeDeviceOrientationReader(
      useSensor: true,
      builder: (context) {
        NativeDeviceOrientation orientation =
            NativeDeviceOrientationReader.orientation(context);

        _buttonPhoto() => Container(
              child: IconButton(
                icon: Icon(
                  CupertinoIcons.circle_filled,
                  color: Colors.white,
                  size: 80,
                ),
                onPressed: () {
                  sizeImage = MediaQuery.of(context).size;
                  bloc.onTakePictureButtonPressed();
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
                          return
                            Stack(
                            children: <Widget>[
                              OverflowBox(
                                maxHeight: size.height,
                                maxWidth: size.height *
                                    previewRatio,
                                child: Image.file(snapshot.data),
                              ),
                              if (widget.imageMask != null)
                                Center(
                                  child: widget.imageMask,
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
                    margin: EdgeInsets.only(top: height - height /4.5),
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
                                          bloc.deletePhoto();
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
//                                          ImageProperties properties = await FlutterNativeImage.getImageProperties(bloc.imagePath.value.path);
//                                          print("properties.width:" + properties.width.toString() +
//                                              " properties.height:" + properties.height.toString());
//                                          File croppedFile = await FlutterNativeImage.cropImage(bloc.imagePath.value.path,
//                                              (properties.width / 16).toInt(), (properties.height / 24).toInt(),
//                                              (properties.width - properties.width / 8).toInt(),
//                                              (properties.height - properties.height / 3.3).toInt());
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
                                      width: 80,
                                      height: 100,
                                      child: IconButton(
                                        icon: Icon(
                                          CupertinoIcons.circle_filled,
                                          color: Colors.white,
                                          size: 76,
                                        ),
                                        onPressed: () {
                                          sizeImage =
                                              MediaQuery.of(context).size;
                                          bloc.onTakePictureButtonPressed();
                                        },
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
                    padding: const EdgeInsets.only(bottom: 10.0, top: 10.0),
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
                                          bloc.deletePhoto();
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