
import 'package:flutter/material.dart';

class PageOne extends StatefulWidget {

  @override
  _PageOneState createState() => _PageOneState();
}

class _PageOneState extends State<PageOne> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('one page'),
      ),
    );
  }
}
