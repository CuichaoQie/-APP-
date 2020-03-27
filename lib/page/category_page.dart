import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';
import 'package:provide/provide.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../service/service_method.dart';
import '../model/category.dart';
import '../model/categoryGoodsList.dart';
import '../provide/child_category.dart';
import '../provide/category_goods_list.dart';

class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('商品分类'),
        ),
        body: Container(
          child: Row(
            children: <Widget>[
              LeftCategoryNavState(),
              Column(
                children: <Widget>[RightCategoryNav(), CategoryGoodsList()],
              )
            ],
          ),
        ));
  }
}

// 左侧大类切换
class LeftCategoryNavState extends StatefulWidget {
  @override
  _LeftCategoryNavStateState createState() => _LeftCategoryNavStateState();
}

class _LeftCategoryNavStateState extends State<LeftCategoryNavState> {
  List list = [];
  int listIndex = 0;

  @override
  void initState() {
    _getCategory();
    // TODO: implement initState
    super.initState();
  }

  void _getCategory() async {
    await postHttp("wxmini/getCategory").then((val) {
      var data = json.decode(val.toString());
      CategoryModel category = CategoryModel.fromJson(data);
      setState(() {
        list = category.data;
      });
      Provide.value<ChildCategory>(context)
          .getChildCategory(list[0].bxMallSubDto, list[0].mallCategoryId);
      _getGoodList(list[0].mallCategoryId);
    });
  }

  void _getGoodList(String categoryId) async {
    var data = {'categoryId': categoryId, 'categorySubId': '', 'page': 1};
    await postHttp('wxmini/getMallGoods', data).then((val) {
      var data = json.decode(val.toString());
      CategoryGoodsListModel goodsList = CategoryGoodsListModel.fromJson(data);
      if (goodsList.data == null) {
        Provide.value<ChildCategory>(context).changeNoMore('没有更多数据');
      } else {
        Provide.value<CateGoryGoodsListProvide>(context)
            .getGoodsList(goodsList.data);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtil().setWidth(180),
      decoration: BoxDecoration(
          border: Border(
        right: BorderSide(width: 1, color: Colors.black12),
      )),
      child: ListView.builder(
        itemBuilder: (context, index) {
          return _leftInkWel(index);
        },
        itemCount: list.length,
      ),
    );
  }

  Widget _leftInkWel(int index) {
    bool isClick = false;
    isClick = index == listIndex ? true : false;
    return InkWell(
      onTap: () {
        var childList = list[index].bxMallSubDto;
        var categoryId = list[index].mallCategoryId;
        Provide.value<ChildCategory>(context)
            .getChildCategory(childList, categoryId);
        setState(() {
          listIndex = index;
        });
        _getGoodList(categoryId);
      },
      child: Container(
        height: ScreenUtil().setHeight(100),
        padding: EdgeInsets.only(left: 10, top: 20),
        decoration: BoxDecoration(
            color: isClick ? Color.fromRGBO(236, 238, 239, 1.0) : Colors.white,
            border: Border(
              bottom: BorderSide(width: 1, color: Colors.black12),
            )),
        child: Text(
          list[index].mallCategoryName,
          style: TextStyle(fontSize: ScreenUtil().setSp(28)),
        ),
      ),
    );
  }
}

class RightCategoryNav extends StatefulWidget {
  @override
  _RightCategoryNavState createState() => _RightCategoryNavState();
}

class _RightCategoryNavState extends State<RightCategoryNav> {
  void _getGoodList(String mallSubId) async {
    var data = {
      'categoryId': Provide.value<ChildCategory>(context).categoryId,
      'categorySubId': mallSubId,
      'page': 1
    };
    await postHttp('wxmini/getMallGoods', data).then((val) {
      var data = json.decode(val.toString());
      CategoryGoodsListModel goodsList = CategoryGoodsListModel.fromJson(data);
      if (goodsList.data == null) {
        Provide.value<ChildCategory>(context).changeNoMore('没有更多数据');
      } else {
        Provide.value<CateGoryGoodsListProvide>(context)
            .getGoodsList(goodsList.data);
      }
    });
  }

  Widget _rightInkWell(BxMallSubDto item, int index) {
    bool isCheck = index == Provide.value<ChildCategory>(context).childIndex
        ? true
        : false;
    return InkWell(
      onTap: () {
        Provide.value<ChildCategory>(context)
            .changeChildIndex(index, item.mallSubId);
        _getGoodList(item.mallSubId);
      },
      child: Container(
        decoration: BoxDecoration(
            color: isCheck ? Color.fromRGBO(236, 238, 239, 1.0) : Colors.white),
        padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
        child: Text(
          item.mallSubName,
          style: TextStyle(fontSize: ScreenUtil().setSp(28)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Provide<ChildCategory>(builder: (context, child, childCategory) {
        return Container(
          height: ScreenUtil().setHeight(80),
          width: ScreenUtil().setWidth(570),
          decoration: BoxDecoration(
              color: Colors.white,
              border:
                  Border(bottom: BorderSide(width: 1, color: Colors.black12))),
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: childCategory.childCategoryList.length,
              itemBuilder: (context, index) {
                return _rightInkWell(
                    childCategory.childCategoryList[index], index);
              }),
        );
      }),
    );
  }
}

class CategoryGoodsList extends StatefulWidget {
  @override
  _CategoryGoodsListState createState() => _CategoryGoodsListState();
}

class _CategoryGoodsListState extends State<CategoryGoodsList> {
  GlobalKey<RefreshFooterState> _footerKey =
      new GlobalKey<RefreshFooterState>();
  var scrollController = new ScrollController();

  Widget _goodsImage(List newList, index) {
    return Container(
      child: Image.network(newList[index].image),
      width: ScreenUtil().setWidth(200),
    );
  }

  Widget _goodsName(List newList, index) {
    return Container(
      padding: EdgeInsets.all(5.0),
      width: ScreenUtil().setWidth(370),
      child: Text(
        newList[index].goodsName,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: ScreenUtil().setSp(28)),
      ),
    );
  }

  Widget _goodsPrice(List newList, index) {
    return Container(
        margin: EdgeInsets.only(top: 20.0),
        width: ScreenUtil().setWidth(370),
        child: Row(children: <Widget>[
          Text(
            '价格:￥${newList[index].presentPrice}',
            style:
                TextStyle(color: Colors.pink, fontSize: ScreenUtil().setSp(30)),
          ),
          Text(
            '￥${newList[index].oriPrice}',
            style: TextStyle(
                color: Colors.black26, decoration: TextDecoration.lineThrough),
          )
        ]));
  }

  Widget _ListWidget(List newList, int index) {
    return InkWell(
        onTap: () {},
        child: Container(
          padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                  bottom: BorderSide(width: 1.0, color: Colors.black12))),
          child: Row(
            children: <Widget>[
              _goodsImage(newList, index),
              Column(
                children: <Widget>[
                  _goodsName(newList, index),
                  _goodsPrice(newList, index)
                ],
              )
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Provide<CateGoryGoodsListProvide>(
      builder: (context, child, data) {
        try {
          if (Provide.value<ChildCategory>(context).page == 1) {
            scrollController.jumpTo(0);
          }
        } catch (e) {
          print('进入页面第一次初始化：${e}');
        }
        if (data.goodsList.length == 0) {
          return Text('暂时没有数据');
        }
        return Expanded(
            child: Container(
          decoration: BoxDecoration(color: Colors.black12),
          width: ScreenUtil().setWidth(570),
          child: EasyRefresh(
            refreshFooter: ClassicsFooter(
                key: _footerKey,
                bgColor: Colors.white,
                textColor: Colors.pink,
                moreInfoColor: Colors.pink,
                showMore: true,
                noMoreText: Provide.value<ChildCategory>(context).noMoreText,
                moreInfo: '加载中',
                loadReadyText: '上拉加载'),
            child: ListView.builder(
                controller: scrollController,
                itemCount: data.goodsList.length,
                itemBuilder: (context, index) {
                  return _ListWidget(data.goodsList, index);
                }),
            loadMore: () async {
              print('上拉加载中');
              _getGoodList();
            },
          ),
        ));
      },
    );
  }

  void _getGoodList() async {
    Provide.value<ChildCategory>(context).addPage();
    var data = {
      'categoryId': Provide.value<ChildCategory>(context).categoryId,
      'categorySubId': Provide.value<ChildCategory>(context).mallSubId,
      'page': Provide.value<ChildCategory>(context).page
    };
    await postHttp('wxmini/getMallGoods', data).then((val) {
      var data = json.decode(val.toString());
      CategoryGoodsListModel goodsList = CategoryGoodsListModel.fromJson(data);
      if (goodsList.data == null) {
        Provide.value<ChildCategory>(context).changeNoMore('没有更多数据');
        Fluttertoast.showToast(
            msg: "已经到底了",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIos: 1,
            backgroundColor: Colors.pink,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        Provide.value<CateGoryGoodsListProvide>(context)
            .addGoodsList(goodsList.data);
      }
    });
  }
}
