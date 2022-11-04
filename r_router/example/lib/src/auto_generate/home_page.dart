import 'dart:async';

import 'package:flutter/material.dart';
import 'package:r_router/r_router.dart';

Future<dynamic> onProcessor(Context context, dynamic result) async {}

FutureOr<bool> onInterceptor(Context ctx) {
  return false;
}

class User {
  int id;
}

@RRouterPageMeta(
    path: '/',
    paramsName: 'homePage',
    pageTransaction: CupertinoPageTransitionsBuilder(),
    processor: onProcessor,
    interceptors: [onInterceptor])
class HomePage extends StatelessWidget {
  final String name;

  @RRouterQueryMeta(def: 1)
  final int age;

  @RRouterBodyMeta(name: "user_name")
  final String userName;

  @RRouterQueryMeta()
  final DateTime now;

  @RRouterQueryMeta()
  final List<String> personalList;

  @RRouterBodyMeta()
  final User user;

  const HomePage(
      {Key key,
      this.name,
      this.age,
      this.userName,
      this.now,
      this.personalList,
      this.user})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
