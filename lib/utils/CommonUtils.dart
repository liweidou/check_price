import 'package:check_price/customWidgets/LoadingDialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CommonUtils {
  static void showLoadingDialog(BuildContext context, String text) {
    showDialog(context: context, builder: (context) => LoadingDialog(text));
  }

}
