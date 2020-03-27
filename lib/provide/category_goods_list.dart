import 'package:flutter/material.dart';
import '../model/categoryGoodsList.dart';

class CateGoryGoodsListProvide with ChangeNotifier {
  List<CategoryListData> goodsList = [];

  getGoodsList(List<CategoryListData> list) {
    goodsList = list;
    notifyListeners();
  }

  addGoodsList(List<CategoryListData> list) {
    goodsList.addAll(list);
    notifyListeners();
  }
}
