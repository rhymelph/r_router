import 'package:flutter/material.dart';
import 'package:r_router/r_router.dart';

class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage({Key key, this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void onNavigateToOne() {
    RRouter.myRouter.navigateTo('/one');
  }

  void onNavigateToTwo() {
    RRouter.myRouter.navigateTo('/two', arguments: {'param': '我是参数(支持实体类)'});
  }

  void onNavigateToTree() {
    RRouter.myRouter.navigateTo('/three', arguments: {'param': '我是参数(支持实体类)'});
  }

  void onNavigateToNotFound() {
    RRouter.myRouter.navigateTo('/home', arguments: {'param': '我是参数(支持实体类)'});
  }

  void onShowDialog() {
    showRDialog(
        builder: (BuildContext context) => AlertDialog(
              title: Text('标题'),
              content: Text('内容'),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('确定'),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        children: <Widget>[
          RaisedButton(onPressed: onNavigateToOne, child: Text('普通跳转')),
          RaisedButton(onPressed: onNavigateToTwo, child: Text('带参数')),
          RaisedButton(onPressed: onNavigateToTree, child: Text('自定义跳转动画')),
          RaisedButton(onPressed: onNavigateToNotFound, child: Text('404')),
          RaisedButton(onPressed: onShowDialog, child: Text('对话框')),
        ],
      ),
    );
  }
}