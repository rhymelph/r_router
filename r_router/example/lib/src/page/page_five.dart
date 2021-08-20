import 'package:flutter/material.dart';
import 'package:r_router/r_router.dart';

class PageFive extends StatefulWidget {
  @override
  _PageFiveState createState() => _PageFiveState();
}

class _PageFiveState extends State<PageFive> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('拦截跳转:${context.readCtx.pathParams.getInt('id', 0)}'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.clear),
        onPressed: () {
          var data = 'test';
          RRouter.maybePop(data);
        },
      ),
    );
  }
}
