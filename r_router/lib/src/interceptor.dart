import 'package:flutter/material.dart';

typedef RRouterRequestCallback = RouteSettings Function(RouteSettings settings);

/// interceptor if you want to interceptor router
class RRouterInterceptor {
  RouteSettings onRequest(RouteSettings settings) => settings;
}

/// interceptor wrapper
class RRouterInterceptorWrapper extends RRouterInterceptor {
  final RRouterRequestCallback _onRequest;

  RRouterInterceptorWrapper({RRouterRequestCallback onRequest})
      : _onRequest = onRequest;

  @override
  RouteSettings onRequest(RouteSettings settings) {
    if (_onRequest != null) {
      return _onRequest.call(settings);
    }
    return super.onRequest(settings);
  }
}
