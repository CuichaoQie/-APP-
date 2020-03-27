import 'package:flutter/material.dart';
import '../provide/counter.dart';
import 'package:provide/provide.dart';

class ProfileCricledPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Container(
        child: Provide<Counter>(builder: (context, child, counter) {
          return Text('${counter.value}');
        }),
      ),
    );
  }
}
