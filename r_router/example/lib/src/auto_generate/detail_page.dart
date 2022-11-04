import 'dart:async';

import 'package:flutter/material.dart';
import 'package:r_router/r_router.dart';

import '../entity/personal.dart';

Future<dynamic> onProcessor(Context context, dynamic result) async {}

FutureOr<bool> onInterceptor(Context ctx) {
  return false;
}

@RRouterPageMeta(
    path: '/:id',
    paramsName: 'detailPage',
    pageTransaction: CupertinoPageTransitionsBuilder(),
    pathRegEx: {'id': '[0-9]'},
    processor: onProcessor,
    interceptors: [onInterceptor])
class DetailPage extends StatelessWidget {
  const DetailPage({Key key, this.id, this.content, this.personal})
      : super(key: key);

  @RRouterPathMeta(name: "id")
  final int id;

  @RRouterQueryMeta(name: "content")
  final String content;

  final Personal personal;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
