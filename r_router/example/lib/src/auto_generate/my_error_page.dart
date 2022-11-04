import 'package:flutter/material.dart';
import 'package:r_router/r_router.dart';

@ErrorPageMeta()
class MyErrorPage extends ErrorPage {
  @override
  Widget errorPage(
      BuildContext context, FlutterErrorDetails flutterErrorDetails) {
    return Center(
      child: Text(
        'Exception Page (${flutterErrorDetails.exceptionAsString()})',
      ),
    );
  }

  @override
  Widget notFoundPage(BuildContext context, Context ctx) {
    return Center(
      child: Text('Page Not found:${ctx.path}'),
    );
  }
}
