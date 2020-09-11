import 'package:flutter/material.dart';
import 'package:r_router/r_router.dart';

@RRouterProvider(
    pageTransitions: ZoomPageTransitionsBuilder(),
    pageBuilderType: RRouterPageBuilderType.cupertino)
class PageOne extends StatefulWidget {
  @override
  _PageOneState createState() => _PageOneState();
}

class _PageOneState extends State<PageOne> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('普通跳转'),
      ),
    );
  }
}
