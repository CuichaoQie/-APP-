import 'package:flutter/material.dart';
import 'package:notepad_app/page/index_page.dart';
import 'package:provide/provide.dart';
import 'package:fluro/fluro.dart';
import 'package:notepad_app/provide/counter.dart';
import 'package:notepad_app/provide/child_category.dart';
import 'package:notepad_app/provide/category_goods_list.dart';
import 'package:notepad_app/provide/details_info.dart';
import 'package:notepad_app/routers/router.dart';
import 'package:notepad_app/routers/application.dart';

void main() {
  var counter = Counter();
  var childCategory = ChildCategory();
  var cateGoryGoodsListProvide = CateGoryGoodsListProvide();
  var detailInfoProvide = DetailInfoProvide();
  var providers = Providers();
  // 路由注册
  final router = Router();
  Routes.configureRouters(router);
  Application.router = router;

  providers
    ..provide(Provider<Counter>.value(counter))
    ..provide(Provider<ChildCategory>.value(childCategory))
    ..provide(
        Provider<CateGoryGoodsListProvide>.value(cateGoryGoodsListProvide))
    ..provide(Provider<DetailInfoProvide>.value(detailInfoProvide));
  runApp(ProviderNode(child: MyApp(), providers: providers));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      child: new MaterialApp(
        title: '商城',
        debugShowCheckedModeBanner: false,
        onGenerateRoute: Application.router.generator,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: IndexPage(),
      ),
    );
  }
}
