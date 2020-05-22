import 'package:dio/dio.dart';

import 'Global.dart';

class DioUtil {
  static Dio dioCreator(bool useToken) {
    Dio dio = Dio();
    dio.interceptors
        .add(InterceptorsWrapper(onRequest: (RequestOptions options) {
      print("\n================== 请求数据 ==========================");
      print("url = ${options.uri.toString()}");
      print("headers = ${options.headers}");
      print("params = ${options.data}");
    }, onResponse: (Response response) {
      print("\n================== 响应数据 ==========================");
      print("code = ${response.statusCode}");
      print("data = ${response.data}");
      print("\n");
    }, onError: (DioError error) {
      print("\n================== 错误响应数据 ======================");
      print("type = ${error.type}");
      print("message = ${error.message}");
      print("stackTrace = ${error.error}");
      print("\n");
    }));
    dio.options.baseUrl = Global.BASE_URL;
    if (useToken) {
      Map<String, String> headers = {"Authorization": Global.API_TOKEN};
      dio.options.headers = headers;
    }
  }

  static Future doGet(
      String url, bool useToken, Function onSuccess, Function onFailed) async {
    Dio dio = dioCreator(useToken);
    Response response = await dio.get(url);
    if (response != null && response.statusCode == 200) {
      onSuccess(response);
    } else {
      onFailed(response);
    }
  }

  static Future doPostForm(String url, Map<String, Object> params,
      bool useToken, Function onSuccess, Function onFailed) async {
    Dio dio = dioCreator(useToken);
    var option = Options(
        method: "POST", contentType: "application/x-www-form-urlencoded");
    Response response = await dio.post(url, data: params, options: option);
    if (response != null && response.statusCode == 200) {
      onSuccess(response);
    } else {
      onFailed(response);
    }
  }

  static Future doPostJson(String url, Map<String, Object> params,
      bool useToken, Function onSuccess, Function onFailed) async {
    Dio dio = dioCreator(useToken);
    var option = Options(method: "POST", contentType: "application/json");
    Response response = await dio.post(url, data: params, options: option);
    if (response != null && response.statusCode == 200) {
      onSuccess(response);
    } else {
      onFailed(response);
    }
  }

  /**
   * 上传文件
   * 注：file是服务端接受的字段字段，如果接受字段不是这个需要修改
   */
  static Future<Response> uploadFile(
      String uploadKey,
      String filePath,
      String fileName,
      String url,
      bool useToken,
      Function onProgress,
      Function onSuccess,
      Function onFailed) async {
    Dio dio = dioCreator(useToken);
    var postData = FormData.fromMap({
      uploadKey: await MultipartFile.fromFile(filePath, filename: fileName)
    }); //uploadKey是服务端接受的字段字段
    var option = Options(
        method: "POST",
        contentType: "multipart/form-data"); //上传文件的content-type 表单
    Response response = await dio.post(
      url,
      data: postData,
      options: option,
      onSendProgress: (int sent, int total) {
        onProgress(sent, total);
        print("上传进度：" + (sent / total * 100).toString() + "%"); //取精度，如：56.45%
      },
    );
    if (response != null && response.statusCode == 200) {
      onSuccess(response);
    } else {
      onFailed(response);
    }
  }

  /**
   * 下载文件
   */
  Future<Response> downloadFile(String resUrl, String savePath, bool useToken,
      Function onProgress, Function onSuccess, Function onFailed) async {
    Dio dio = dioCreator(useToken);
    Response response = await dio.download(resUrl, savePath,
        onReceiveProgress: (int loaded, int total) {
          onProgress(loaded, total);
          print("上传进度：" + (loaded / total * 100).toString() + "%"); //取精度，如：56.45%
    });
    if (response != null && response.statusCode == 200) {
      onSuccess(response);
    } else {
      onFailed(response);
    }
  }
}
