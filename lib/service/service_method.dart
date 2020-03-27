import 'package:dio/dio.dart';
import 'dart:async';
import 'dart:io';

const serviceUrl =
    'http://v.jspang.com:8088/baixing/'; //此端口针对于正版用户开放，可自行fiddle获取。

Future getHttp(String path, Object query) async {
  try {
    Response response;
    Dio dio = new Dio();
    dio.options.contentType =
        ContentType.parse("application/x-www-form-urlencoded");
    response = await dio.get(serviceUrl + path, queryParameters: query);
    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('后端接口出现异常，请检测代码和服务器情况.........');
    }
  } catch (e) {
    return e;
  }
}

Future postHttp(String path, [Object data]) async {
  try {
    Response response;
    Dio dio = new Dio();
    dio.options.contentType =
        ContentType.parse("application/x-www-form-urlencoded");
    response = await dio.post(serviceUrl + path, data: data);
    print(response.statusCode);
    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('后端接口出现异常，请检测代码和服务器情况.........');
    }
  } catch (e) {
    return e;
  }
}
