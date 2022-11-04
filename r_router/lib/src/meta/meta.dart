import 'package:flutter/material.dart';

import '../../r_router.dart';

/// auto generate error page code
///
/// RRouter.setErrorPage([Your Class])
class ErrorPageMeta {
  const ErrorPageMeta();
}

/// auto generate router page code
///
class RRouterPageMeta {
  final String? path;
  final String? paramsName;
  final Map<String, String>? pathRegEx;
  final PageTransitionsBuilder? pageTransaction;
  final List<RouteInterceptor>? interceptors;
  final ResponseProcessor? processor;

  const RRouterPageMeta(
      {required this.path,
      this.paramsName,
      this.pathRegEx,
      this.processor,
      this.pageTransaction,
      this.interceptors});
}

class RRouterQueryMeta {
  final String? name;
  final dynamic def;

  const RRouterQueryMeta({
    this.name,
    this.def,
  });
}

class RRouterPathMeta {
  final String? name;
  final dynamic def;

  const RRouterPathMeta({
    this.name,
    this.def,
  });
}

class RRouterBodyMeta {
  final String? name;
  final dynamic def;

  const RRouterBodyMeta({
    this.name,
    this.def,
  });
}
