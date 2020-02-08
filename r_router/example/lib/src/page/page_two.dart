import 'package:flutter/material.dart';

class PageTwo extends StatefulWidget {
  final String param;

  const PageTwo({Key key, this.param}) : super(key: key);

  @override
  _PageTwoState createState() => _PageTwoState();
}

class _PageTwoState extends State<PageTwo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.param),
      ),
    );
  }
}
