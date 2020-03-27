import 'package:flutter/material.dart';
import 'package:notepad_app/model/details.dart';
import 'package:notepad_app/service/service_method.dart';
import 'dart:convert';

class DetailInfoProvide with ChangeNotifier {
  DetailsModel goodsInfo = null;

  getGoodsInfo(String id) {
    postHttp('wxmini/getGoodsDetailById', {'goodId': id}).then((val) {
      var data = json.decode(val.toString());
      print(data);
//      goodsInfo = DetailsModel.fromJson(data);
//      print(goodsInfo);
      notifyListeners();
    }).catchError((error) {
      print(error);
    });
  }
}
