import 'package:flutter/material.dart';
import 'package:r_router/r_router.dart';

class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage({Key key, this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  void onNavigateToPage(String page) {
    RRouter.myRouter.navigateTo(page, arguments: {'pageThree': 'hello world!'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton(
                onPressed: () => onNavigateToPage('/one'), child: Text('one')),
            FlatButton(
                onPressed: () => onNavigateToPage('/two'), child: Text('two')),
            FlatButton(
                onPressed: () => onNavigateToPage('/three'),
                child: Text('three')),
          ],
        ),
      ),
    );
  }
}
