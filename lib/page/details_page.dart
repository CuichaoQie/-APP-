import 'package:flutter/material.dart';
import 'package:provide/provide.dart';
import '../provide/details_info.dart';

class DetailsPage extends StatelessWidget {
  final String goodsId;

  DetailsPage(this.goodsId);

  @override
  Widget build(BuildContext context) {
    _getBackInfo(context);
    return Container(child: Text('商品ID为：${goodsId}'));
  }

  void _getBackInfo(context) async {
    await Provide.value<DetailInfoProvide>(context).getGoodsInfo(goodsId);
    print('详情页');
  }
}
