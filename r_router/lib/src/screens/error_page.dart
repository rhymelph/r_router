import 'package:flutter/material.dart';
import '../common/r_router.dart';

abstract class ErrorPage {
  Widget notFoundPage(BuildContext context, Context ctx);

  Widget errorPage(
      BuildContext context, FlutterErrorDetails flutterErrorDetails);
}

class ErrorPageWrapper implements ErrorPage {
  final Widget Function(BuildContext context, Context ctx) notFound;
  final Widget Function(
      BuildContext context, FlutterErrorDetails flutterErrorDetails) error;

  ErrorPageWrapper({required this.notFound, required this.error});

  @override
  Widget errorPage(
      BuildContext context, FlutterErrorDetails flutterErrorDetails) {
    return error(context, flutterErrorDetails);
  }

  @override
  Widget notFoundPage(BuildContext context, Context ctx) {
    return notFound(context, ctx);
  }
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
    return Center(
      child: Text(
        'Exception Page (${flutterErrorDetails.exceptionAsString()})',
      ),
    );
  }
}
