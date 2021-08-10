import 'dart:async';

import 'package:flutter/material.dart';
import 'package:r_router/src/common/context.dart';

abstract class ErrorPage {
  Widget notFoundPage(BuildContext context, Context ctx);

  Widget errorPage(
      BuildContext context, FlutterErrorDetails flutterErrorDetails);
}

class DefaultErrorPage implements ErrorPage {
  @override
  Widget notFoundPage(BuildContext context, Context ctx) {
    return Scaffold(
      body: Center(
        child: Text(
          'Page Not Found:${ctx.uri.toString()}',
          style: Theme.of(context).textTheme.headline3,
        ),
      ),
    );
  }

  @override
  Widget errorPage(
      BuildContext context, FlutterErrorDetails flutterErrorDetails) {
    return Scaffold(
      body: Center(
        child: Text(
          'Exception Page (${flutterErrorDetails.exceptionAsString()})',
          style: Theme.of(context).textTheme.headline3,
        ),
      ),
    );
  }
}
