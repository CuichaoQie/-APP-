import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:notepad_app/routers/application.dart';
import 'package:notepad_app/service/service_method.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  GlobalKey<RefreshFooterState> _footerKey =
      new GlobalKey<RefreshFooterState>();

  int page = 1;
  List<Map> hotGoodsList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text('商城'),
        ),
        body: FutureBuilder(
          future: postHttp('wxmini/homePageContent',
              {'lon': '115.02932', 'lat': '35.76189'}),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var data = json.decode(snapshot.data.toString());
              var responseData = data['data'];
              List<Map> swiperDataList =
                  (responseData['slides'] as List).cast();
              List<Map> navigatorList =
                  (responseData['category'] as List).cast();
              String advertesPicture =
                  responseData['advertesPicture']['PICTURE_ADDRESS'];
              String leaderImage = responseData['shopInfo']['leaderImage'];
              String leaderPhone = responseData['shopInfo']['leaderPhone'];
              List<Map> recommendList =
                  (responseData['recommend'] as List).cast();
              String floor1Title =
                  responseData['floor1Pic']['PICTURE_ADDRESS']; //楼层1的标题图片
              String floor2Title =
                  responseData['floor2Pic']['PICTURE_ADDRESS']; //楼层1的标题图片
              String floor3Title =
                  responseData['floor3Pic']['PICTURE_ADDRESS']; //楼层1的标题图片
              List<Map> floor1 =
                  (responseData['floor1'] as List).cast(); //楼层1商品和图片
              List<Map> floor2 =
                  (responseData['floor2'] as List).cast(); //楼层1商品和图片
              List<Map> floor3 =
                  (responseData['floor3'] as List).cast(); //楼层1商品和图片
              return EasyRefresh(
                loadMore: () async {
                  print('请求中');
                  await postHttp('wxmini/homePageBelowConten', {'page': page})
                      .then((val) {
                    var data = json.decode(val.toString());
                    List<Map> newHotGoodsList = (data['data'] as List).cast();
                    setState(() {
                      hotGoodsList.addAll(newHotGoodsList);
                      page++;
                    });
                  }).catchError((onError) {
                    print(onError);
                  });
                },
                refreshFooter: ClassicsFooter(
                    key: _footerKey,
                    bgColor: Colors.white,
                    textColor: Colors.pink,
                    moreInfoColor: Colors.pink,
                    showMore: true,
                    noMoreText: '',
                    moreInfo: '加载中',
                    loadReadyText: '上拉加载....'),
                child: ListView(
                  children: <Widget>[
                    SwiperDiy(swiperDataList: swiperDataList),
                    TopNavigator(navigatorList: navigatorList),
                    AdBanner(advertesPicture: advertesPicture),
                    LeaderPhone(
                        leaderImage: leaderImage, leaderPhone: leaderPhone),
                    RecommendList(
                        recommendList: [...recommendList, ...recommendList]),
                    FloorTitle(picture_address: floor1Title),
                    FloorContent(floorGoodsList: floor1),
                    FloorTitle(picture_address: floor2Title),
                    FloorContent(floorGoodsList: floor2),
                    FloorTitle(picture_address: floor3Title),
                    FloorContent(floorGoodsList: floor3),
                    _hotGoods()
                  ],
                ),
              );
            } else {
              return Center(
                child: Text('加载中'),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _hotTitle = Container(
    margin: EdgeInsets.only(top: 10),
    padding: EdgeInsets.all(5),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border(bottom: BorderSide(width: 0.5, color: Colors.black12)),
    ),
    child: Text('火爆专区'),
  );

  Widget _warpList() {
    if (hotGoodsList.length != 0) {
      List<Widget> listWidget = hotGoodsList.map((v) {
        return InkWell(
          onTap: () {
            print('点击商品');
            Application.router.navigateTo(context, '/detail?id=${1}');
          },
          child: Container(
              color: Colors.white,
              padding: EdgeInsets.all(5),
              margin: EdgeInsets.only(bottom: 3),
              width: ScreenUtil().setWidth(372),
              child: Column(
                children: <Widget>[
                  Image.network(
                    v['image'],
                    width: ScreenUtil().setWidth(375),
                  ),
                  Text(
                    v['name'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.pink, fontSize: ScreenUtil().setSp(26)),
                  ),
                  Row(
                    children: <Widget>[
                      Text('￥${v['mallPrice']}'),
                      Text(
                        '￥${v['price']}',
                        style: TextStyle(
                            color: Colors.black26,
                            decoration: TextDecoration.lineThrough),
                      )
                    ],
                  )
                ],
              )),
        );
      }).toList();
      return Wrap(
        spacing: 2,
        children: listWidget,
      );
    } else {
      return Container(
        child: Text(
          '暂无数据',
          textAlign: TextAlign.center,
        ),
      );
    }
  }

  Widget _hotGoods() {
    return Container(
      child: Column(
        children: <Widget>[_hotTitle, _warpList()],
      ),
    );
  }
}

// 首页轮播
class SwiperDiy extends StatelessWidget {
  final List swiperDataList;

  SwiperDiy({Key key, this.swiperDataList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      width: ScreenUtil().setWidth(750),
      height: ScreenUtil().setHeight(275),
      child: new Swiper(
        itemBuilder: (BuildContext context, int index) {
          return Image.network(
            swiperDataList[index]['image'],
            width: ScreenUtil().setWidth(750),
          );
        },
        itemCount: swiperDataList.length,
        autoplay: true,
        pagination: SwiperPagination(),
      ),
    );
  }
}

// 顶部导航
class TopNavigator extends StatelessWidget {
  final List navigatorList;

  TopNavigator({Key key, this.navigatorList}) : super(key: key);

  Widget _grideViewItem(BuildContext context, item) {
    return InkWell(
      onTap: () {
        print('点击');
      },
      child: Column(
        children: <Widget>[
          Image.network(item['image'], width: ScreenUtil().setWidth(95)),
          Text(item['mallCategoryName']),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (navigatorList.length > 10) {
      navigatorList.removeRange(10, navigatorList.length);
    }
    // TODO: implement build
    return Container(
      height: ScreenUtil().setHeight(280),
      padding: EdgeInsets.all(5.0),
      child: GridView.count(
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 5,
        children: navigatorList.map((item) {
          return _grideViewItem(context, item);
        }).toList(),
      ),
    );
  }
}

// 首页banner
class AdBanner extends StatelessWidget {
  final String advertesPicture;

  AdBanner({Key key, this.advertesPicture}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Image.network(advertesPicture),
    );
  }
}

// 联系我们
class LeaderPhone extends StatelessWidget {
  final String leaderImage; //店长图片
  final String leaderPhone; //店长电话

  LeaderPhone({Key key, this.leaderImage, this.leaderPhone}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: InkWell(
        onTap: _launchURL,
        child: Image.network(leaderImage),
      ),
    );
  }

  void _launchURL() async {
    String url = 'https://www.baidu.com';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

class RecommendList extends StatelessWidget {
  final List recommendList;

  RecommendList({Key key, this.recommendList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().setHeight(387),
      margin: EdgeInsets.only(top: 10.0),
      child: Column(
        children: <Widget>[_titleWidget(), _recomendList()],
      ),
    );
  }

  Widget _titleWidget() {
    return Container(
      height: ScreenUtil().setHeight(40),
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(left: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(width: 0.1, color: Colors.black),
        ),
      ),
      child: Text(
        '商品列表',
        style: TextStyle(color: Colors.pink),
      ),
    );
  }

  Widget _recomendList() {
    return Container(
      height: ScreenUtil().setHeight(347),
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: recommendList.length,
          itemBuilder: (context, index) {
            return _item(index);
          }),
    );
  }

  Widget _item(index) {
    return InkWell(
        onTap: () {
          print(recommendList[index]['mallPrice']);
        },
        child: Container(
          height: ScreenUtil().setHeight(347),
          width: ScreenUtil().setWidth(250),
          padding: EdgeInsets.all(8),
          child: Column(
            children: <Widget>[
              Image.network(recommendList[index]['image']),
              Text('￥${recommendList[index]['mallPrice']}'),
              Text(
                '￥${recommendList[index]['price']}',
                style: TextStyle(
                    decoration: TextDecoration.lineThrough, color: Colors.grey),
              )
            ],
          ),
        ));
  }
}

class FloorTitle extends StatelessWidget {
  final String picture_address;

  FloorTitle({Key key, this.picture_address}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      child: Image.network(picture_address),
    );
  }
}

class FloorContent extends StatelessWidget {
  final List floorGoodsList;

  FloorContent({Key key, this.floorGoodsList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      child: Column(
        children: <Widget>[_firstRow(), _ortherGoogs()],
      ),
    );
  }

  Widget _firstRow() {
    return Row(
      children: <Widget>[
        _goodItem(floorGoodsList[0]),
        Column(
          children: <Widget>[
            _goodItem(floorGoodsList[1]),
            _goodItem(floorGoodsList[2]),
          ],
        )
      ],
    );
  }

  Widget _ortherGoogs() {
    return Row(
      children: <Widget>[
        _goodItem(floorGoodsList[3]),
        _goodItem(floorGoodsList[4])
      ],
    );
  }

  Widget _goodItem(Map goods) {
    return Container(
      width: ScreenUtil().setWidth(375),
      child: InkWell(
        child: Image.network(goods['image']),
      ),
    );
  }
}
