

import 'package:flutter/material.dart';

class PageThree extends StatefulWidget {
  final String pageThree;

  const PageThree({Key key, this.pageThree}) : super(key: key);

  @override
  _PageThreeState createState() => _PageThreeState();
}

class _PageThreeState extends State<PageThree> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('three page'),
      ),
      body: Center(
        child: Text(widget.pageThree),
      ),
    );
  }
}
