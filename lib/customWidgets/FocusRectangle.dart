import 'package:flutter/material.dart';

class FocusRectangle extends StatefulWidget {
  Color color;
  FocusRectangleState focusRectangleState;

  FocusRectangle({Key key, this.color}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    focusRectangleState = FocusRectangleState(
      color: color,
    );
    return focusRectangleState;
  }
}

class FocusRectangleState extends State<FocusRectangle> {
  Color color;

  FocusRectangleState({Key key, this.color});

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
          Container(
            margin: EdgeInsets.only(
                left: MediaQuery.of(context).size.width / 10,
                right: MediaQuery.of(context).size.width / 10,
                top: MediaQuery.of(context).size.height / 16),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 6,
            child: Text(""),
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                blurRadius: 2, //阴影范
                color: Color(0x00000000),
                offset: Offset(1, 1),
              ),
            ], border: Border.all(color: Colors.white, width: 2),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 4 + 1,
            left: MediaQuery.of(context).size.width / 2 - 140,
            child: Container(
              width: 280,
              alignment: Alignment.center,
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                  blurRadius: 2, //阴影范
                  color: Color(0x3f000000),
                  offset: Offset(1, 1),
                ),
              ], border: Border.all(color: Colors.transparent, width: 2),
              ),
              child: Text(
                "收據商標一定要放在框線內",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
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
    Size size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;

    reactPath.moveTo(width / 10, height / 24);
    reactPath.lineTo(width / 10, height / 9);
    reactPath.lineTo(width - width / 10, height / 9);
    reactPath.lineTo(width - width / 10, height / 24);

    path.addPath(reactPath, Offset(0, 0));
    path.addRect(Rect.fromLTWH(0.0, 0.0, width, height));
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

  double getIntDoubleValue(double originDouble) {
    int a = originDouble.toInt();
    return a.toDouble();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
