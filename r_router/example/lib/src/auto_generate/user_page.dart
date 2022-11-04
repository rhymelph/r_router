import 'dart:async';

import 'package:flutter/material.dart';
import 'package:r_router/r_router.dart';

Future<dynamic> onProcessor(Context context, dynamic result) async {}

FutureOr<bool> onInterceptor(Context ctx) {
  return false;
}

@RRouterPageMeta(
    path: '/user',
    paramsName: 'userPage',
    pageTransaction: CupertinoPageTransitionsBuilder(),
    processor: onProcessor,
    interceptors: [onInterceptor])
class UserPage extends StatelessWidget {
  const UserPage({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
