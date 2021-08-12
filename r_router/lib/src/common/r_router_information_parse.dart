part of 'r_router.dart';

class RRouterInformationParser extends RouteInformationParser<Page<dynamic>> {
  @override
  Future<Page<dynamic>> parseRouteInformation(
      RouteInformation routeInformation) async {
    String path = routeInformation.location ?? '/';
    Object? body = routeInformation.state;
    PageTransitionsBuilder? _pageTransitions;
    final ctx = Context(
      path,
      body: body,
    );
    WidgetBuilder? builder;
    NavigatorRoute? handler = RRouter._register.match(ctx.uri);
    if (handler != null) {
      builder = await handler(ctx);
      _pageTransitions = handler.defaultPageTransaction;
    }
    _pageTransitions ??= const OpenUpwardsPageTransitionsBuilder();

    builder ??=
        (BuildContext context) => RRouter._errorPage.notFoundPage(context, ctx);
    return RRouter._pageNamed(ctx, builder, _pageTransitions);
  }

  @override
  RouteInformation? restoreRouteInformation(Page<dynamic> configuration) {
    return RouteInformation(
        location: configuration.name, state: configuration.arguments);
  }
}
