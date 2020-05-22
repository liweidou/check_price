import 'package:flutter/material.dart';

class CameraFocus {
  CameraFocus._();

  static Widget rectangle({Color color}) => _FocusRectangle(color: color);

  static Widget circle({Color color}) => _FocusCircle(
        color: color,
      );

  static Widget square({Color color}) => _FocusSquare(
        color: color,
      );
}

class _FocusSquare extends StatelessWidget {
  final Color color;

  const _FocusSquare({Key key, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: <Widget>[
          ClipPath(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: color,
            ),
            clipper: _SquareModePhoto(),
          ),
          Positioned(
            top: 100,
            left: MediaQuery.of(context).size.width / 2 - 100,
            child: Container(
              width: 200,
              child: Text(
                "請把小票放在框内對焦，否則可能導致文字識別不準確！",
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _SquareModePhoto extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    var reactPath = Path();

    reactPath.moveTo(size.width / 20, size.height * 2 / 6);
    reactPath.lineTo(size.width - size.width / 20, size.height * 2 / 6);
    reactPath.lineTo(size.width - size.width / 20, size.height * 4 / 6);
    reactPath.lineTo(size.width / 20, size.height * 4 / 6);

    path.addPath(reactPath, Offset(0, 0));
    path.addRect(Rect.fromLTWH(0.0, 0.0, size.width, size.height));
    path.fillType = PathFillType.evenOdd;
/*
    path.moveTo(size.width/4, size.height/4);
    path.lineTo(size.width/4, size.height*3/4);
    path.lineTo(size.width*3/4, size.height*3/4);
    path.lineTo(size.width*3/4, size.height/4);
*/
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

class _FocusRectangle extends StatelessWidget {
  final Color color;

  const _FocusRectangle({Key key, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: <Widget>[
          ClipPath(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: color,
            ),
            clipper: _RectangleModePhoto(context),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height - MediaQuery.of(context).size.height/ 3.5 + 8,
            left: MediaQuery.of(context).size.width / 2 - 100,
            child: Container(
              width: 200,
              child: Text(
                "收據左右兩邊需要放在框內 相片要對焦要清",
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _RectangleModePhoto extends CustomClipper<Path> {
  BuildContext context;

  _RectangleModePhoto(this.context);

  @override
  Path getClip(Size size) {
    var path = Path();
    var reactPath = Path();

    print("size.width:" + MediaQuery.of(context).size.width.toString() +
        " size.height:" + MediaQuery.of(context).size.height.toString());

    reactPath.moveTo(getIntDoubleValue(MediaQuery.of(context).size.width / 16),
        getIntDoubleValue(MediaQuery.of(context).size.height / 24));
    reactPath.lineTo(getIntDoubleValue(MediaQuery.of(context).size.width / 16),
        getIntDoubleValue(MediaQuery.of(context).size.height - MediaQuery.of(context).size.height / 3.5));
    reactPath.lineTo(getIntDoubleValue(MediaQuery.of(context).size.width - size.width / 16),
        getIntDoubleValue(MediaQuery.of(context).size.height - MediaQuery.of(context).size.height / 3.5));
    reactPath.lineTo(getIntDoubleValue(MediaQuery.of(context).size.width - MediaQuery.of(context).size.width / 16) ,
        getIntDoubleValue(MediaQuery.of(context).size.height / 24));

    path.addPath(reactPath, Offset(0, 0));
    path.addRect(Rect.fromLTWH(0.0, 0.0, size.width, MediaQuery.of(context).size.height));
    path.fillType = PathFillType.evenOdd;
/*
    path.moveTo(size.width/4, size.height/4);
    path.lineTo(size.width/4, size.height*3/4);
    path.lineTo(size.width*3/4, size.height*3/4);
    path.lineTo(size.width*3/4, size.height/4);
*/
    path.close();
    return path;
  }

  double getIntDoubleValue(double originDouble){
    int a = originDouble.toInt();
    return a.toDouble();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

class _FocusCircle extends StatelessWidget {
  final Color color;

  const _FocusCircle({Key key, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ClipPath(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: color,
        ),
        clipper: _CircleModePhoto(),
      ),
    );
  }
}

class _CircleModePhoto extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return new Path()
      ..addOval(new Rect.fromCircle(
          center: new Offset(size.width / 2, size.height / 2),
          radius: size.width * 0.4))
      ..addRect(new Rect.fromLTWH(0.0, 0.0, size.width, size.height))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
