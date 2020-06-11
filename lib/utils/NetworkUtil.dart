import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:check_price/beans/LoginResponeBean.dart';
import 'package:check_price/beans/RefreshTokenResponeBean.dart';
import 'package:check_price/utils/CommonUtils.dart';
import 'package:connectivity/connectivity.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:imei_plugin/imei_plugin.dart';
import 'package:sentry/sentry.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Global.dart';

class NetworkUtil {
//  response.bodyBytes

  static SentryClient sentry = new SentryClient(
      dsn:
          "https://62a899ce780444e2988004ef102fddfe@o264632.ingest.sentry.io/5259902");

  static Future<bool> isConnected() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  static String getRequestUrl(String url) {
    return Global.BASE_URL + url;
  }

  static Future postWithBody(String url, var body, bool useToken,
      Function onSuccess, Function onFailed) async {
    http.Response response = null;
    if (useToken) {
      Map<String, String> headers = {
        "Authorization": Global.API_TOKEN,
        "content-type": "application/json"
      };
      response =
          await http.post(getRequestUrl(url), headers: headers, body: body);
    } else {
      Map<String, String> headers = {"content-type": "application/json"};
      response =
          await http.post(getRequestUrl(url), headers: headers, body: body);
    }
    print("url:" +
        getRequestUrl(url) +
        " statuscode:" +
        response.statusCode.toString());
    if (response != null &&
        response.statusCode >= 200 &&
        response.statusCode < 300) {
      print("response:" + response.body);
      onSuccess(response);
    } else {
      print("erro:" + response.reasonPhrase);
      onFailed(response);
      await sentry.captureException(
        exception: response.statusCode,
        stackTrace: response.reasonPhrase,
      );
    }
  }

  static Future post(
      String url, bool useToken, Function onSuccess, Function onFailed) async {
    http.Response response = null;
    if (useToken) {
      Map<String, String> headers = {
        "Authorization": Global.API_TOKEN,
        "content-type": "application/json"
      };
      response = await http.post(getRequestUrl(url), headers: headers);
    } else {
      Map<String, String> headers = {"content-type": "application/json"};
      response = await http.post(getRequestUrl(url), headers: headers);
    }
    print("url:" +
        getRequestUrl(url) +
        " statuscode:" +
        response.statusCode.toString());
    if (response != null &&
        response.statusCode >= 200 &&
        response.statusCode < 300) {
      onSuccess(response);
      print("response:" + response.body);
    } else {
      if(response.statusCode == 401){
        doLogin((){
          post(url,  useToken,
              onSuccess, onFailed);
        });
      }else if(response.statusCode == 400){
        Global.preferences.setString(Global.REFRESH_TOKEN_KEY, "");
        doLogin((){
          post(url, useToken,
              onSuccess, onFailed);
        });
      }
      onFailed(response.reasonPhrase);
      print("erro:" + response.reasonPhrase);
      await sentry.captureException(
        exception: response.statusCode,
        stackTrace: response.reasonPhrase,
      );
    }
  }

  static Future get(
      String url, bool useToken, Function onSuccess, Function onFailed) async {
    http.Response response = null;
    if (useToken) {
      Map<String, String> headers = {"Authorization": Global.API_TOKEN};
      response = await http.get(getRequestUrl(url), headers: headers);
    } else
      response = await http.get(getRequestUrl(url));
    print("url:" +
        getRequestUrl(url) +
        " statuscode:" +
        response.statusCode.toString());
    if (response != null &&
        response.statusCode >= 200 &&
        response.statusCode < 300) {
      onSuccess(response);
      print("response:" + response.body);
    } else {
      onFailed(response);
      print("responseerro:" + response.body);
      print("erro:" + response.reasonPhrase);
      await sentry.captureException(
        exception: response.statusCode,
        stackTrace: response.reasonPhrase,
      );
    }
  }

  static Future delete(
      String url, bool useToken, Function onSuccess, Function onFailed) async {
    http.Response response = null;
    if (useToken) {
      Map<String, String> headers = {"Authorization": Global.API_TOKEN};
      response = await http.delete(getRequestUrl(url), headers: headers);
    } else
      response = await http.delete(getRequestUrl(url));
    if (response != null &&
        response.statusCode >= 200 &&
        response.statusCode < 300)
      onSuccess(response);
    else {
      onFailed(response.reasonPhrase);
      await sentry.captureException(
        exception: response.statusCode,
        stackTrace: response.reasonPhrase,
      );
    }
  }

  static Future put(
      String url, bool useToken, Function onSuccess, Function onFailed) async {
    http.Response response = null;
    if (useToken) {
      Map<String, String> headers = {"Authorization": Global.API_TOKEN};
      response = await http.put(getRequestUrl(url), headers: headers);
    } else
      response = await http.put(getRequestUrl(url));
    if (response != null &&
        response.statusCode >= 200 &&
        response.statusCode < 300)
      onSuccess(response);
    else {
      onFailed(response.reasonPhrase);
      await sentry.captureException(
        exception: response.statusCode,
        stackTrace: response.reasonPhrase,
      );
    }
  }

  static Future putWithParams(String url, Map<String, Object> params,
      bool useToken, Function onSuccess, Function onFailed) async {
    http.Response response = null;
    if (useToken) {
      Map<String, String> headers = {"Authorization": Global.API_TOKEN};
      response =
          await http.put(getRequestUrl(url), headers: headers, body: params);
    } else
      response = await http.put(getRequestUrl(url), body: params);
    if (response != null &&
        response.statusCode >= 200 &&
        response.statusCode < 300)
      onSuccess(response);
    else {
      onFailed(response.reasonPhrase);
      await sentry.captureException(
        exception: response.statusCode,
        stackTrace: response.reasonPhrase,
      );
    }
  }

  static void doLogin(Function afterSetToken) async {
    NetworkUtil.isConnected().then((value) async {
      if (value) {
        String refreshTokenValue =
            Global.preferences.getString(Global.REFRESH_TOKEN_KEY);
        if (refreshTokenValue == null || refreshTokenValue.isEmpty) {
          var params = {
            "username": Global.USER_NAME,
            "password": Global.USER_PASSWORD
          };
          var body = utf8.encode(json.encode(params));
          await NetworkUtil.postWithBody("/api/token", body, false, (response) {
            LoginResponeBean loginResponeBean = LoginResponeBean.fromJson(
                jsonDecode(Utf8Decoder().convert(response.bodyBytes)));
            Global.API_TOKEN =
                Global.TOKEN_PREFIX + " " + loginResponeBean.token;
            Global.preferences
                .setString(Global.REFRESH_TOKEN_KEY, loginResponeBean.token);
            afterSetToken();
            cycleRefreshToken();
          }, (erro) {});
        } else {
          var params = {"token": refreshTokenValue};
          var body = utf8.encode(json.encode(params));
          await NetworkUtil.postWithBody("/api/token/refresh", body, false,
              (response) {
            RefreshTokenResponeBean loginResponeBean =
                RefreshTokenResponeBean.fromJson(
                    jsonDecode(Utf8Decoder().convert(response.bodyBytes)));
            Global.API_TOKEN =
                Global.TOKEN_PREFIX + " " + loginResponeBean.token;
            afterSetToken();
            cycleRefreshToken();
          }, (erro) {
            Global.preferences.setString(Global.REFRESH_TOKEN_KEY, "");
            doLogin(afterSetToken);
          });
        }
      } else {
        Fluttertoast.showToast(msg: "請檢查網絡！");
      }
    });
  }

  static void cycleRefreshToken() {
    Global.timer?.cancel();
    Global.timer = Timer.periodic(Duration(minutes: 5), (timer) {
      NetworkUtil.doLogin(() {});
    });
  }

  static void registerDevice(BuildContext context,Function afterRegister) async {
    print("registerDevice");
    if (Global.preferences.getBool(Global.NO_REGISTER_DEVICE) == null ||
        Global.preferences.getBool(Global.NO_REGISTER_DEVICE)) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      String platformImei;
      String ostype;
      String deviceversion;
      try {
        if (Platform.isAndroid) {
          AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
          ostype = "android";
          platformImei = await ImeiPlugin.getImei(
              shouldShowRequestPermissionRationale: false);
          deviceversion = androidInfo.version.release;
        } else if (Platform.isIOS) {
          // e.g. "Moto G (4)"
          print("registerDeviceisIOS");
          IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
          platformImei = await ImeiPlugin.getImei();
          ostype = "ios";
          deviceversion = iosInfo.systemVersion;
          print("registerDeviceisIOSplatformImei:" + platformImei);
        }
      } on PlatformException {
        platformImei = 'Failed to get platform version.';
      }
      var params = {
        "ostype": ostype,
        "deviceime": platformImei,
        "deviceversion": deviceversion
      };
      print("params:" + params.toString());
      var body = utf8.encode(json.encode(params));
      await NetworkUtil.postWithBody("/api/device/register", body, true,
          (respone) {
        Global.preferences.setBool(Global.NO_REGISTER_DEVICE, false);
        afterRegister();
      }, (erro) {
        Fluttertoast.showToast(msg: "注册设备失败:" + erro.toString());
      });
    }
  }
}
