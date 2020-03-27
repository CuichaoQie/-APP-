import 'package:flutter/material.dart';
import '../model/category.dart';

class ChildCategory with ChangeNotifier {
  List<BxMallSubDto> childCategoryList = [];
  int childIndex = 0;
  String categoryId = '4';
  String mallSubId = '';

  int page = 1;
  String noMoreText = '';

  getChildCategory(List<BxMallSubDto> list, String id) {
    //
    childIndex = 0;
    categoryId = id;
    //------------------关键代码start
    page = 1;
    noMoreText = '';
    //
    mallSubId = ''; //点击大类时，把子类ID清空
    //
    BxMallSubDto all = BxMallSubDto();
    all.mallSubId = '00';
    all.mallCategoryId = '00';
    all.mallSubName = '全部';
    all.comments = 'null';
    childCategoryList = [all];
    childCategoryList.addAll(list);
    notifyListeners();
  }

  changeChildIndex(int index, String id) {
    childIndex = index;
    mallSubId = id;
    //------------------关键代码start
    page = 1;
    noMoreText = ''; //显示更多的表示
    //
    notifyListeners();
  }

  //增加Page的方法f
  addPage() {
    page++;
  }

  //改变noMoreText数据
  changeNoMore(String text) {
    noMoreText = text;
    notifyListeners();
  }
}
