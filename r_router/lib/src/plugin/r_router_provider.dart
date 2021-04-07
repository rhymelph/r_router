import 'package:flutter/material.dart';

import '../../r_router.dart';

/// use to RRouterPlugin.
class RRouterProvider {
  final String paramName;
  final RRouterPageBuilderType? pageBuilderType;
  final PageTransitionsBuilder? pageTransitions;
  final String? path;
  final String? description;

  const RRouterProvider(
      {required this.paramName,
      this.pageTransitions,
      this.pageBuilderType,
      this.path,
      this.description});
}
