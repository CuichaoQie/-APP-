import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import './router_handler.dart';

class Routes {
  static String root = '/';
  static String detailsPage = '/detail';

  static void configureRouters(Router router) {
    router.notFoundHandler = new Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      print('error ===> router is not found');
    });
    router.define(detailsPage, handler: detailsHandler);
  }
}
