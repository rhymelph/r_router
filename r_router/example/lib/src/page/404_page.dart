import 'package:flutter/material.dart';

class NoFoundPage extends StatefulWidget {
  final String path;

  const NoFoundPage({Key key, this.path}) : super(key: key);
  @override
  _NoFoundPageState createState() => _NoFoundPageState();
}

class _NoFoundPageState extends State<NoFoundPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('404'),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Text('找不到${widget.path}路径的页面'),
      ),
    );
  }
}
