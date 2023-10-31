part of 'r_router.dart';

class RRouterInformationParser extends RouteInformationParser<Page<dynamic>> {
  @override
  Future<Page<dynamic>> parseRouteInformation(
      RouteInformation routeInformation) async {
    routeInformation.location;
    String path = routeInformation.location ?? '/';
    Object? body = routeInformation.state;
    PageTransitionsBuilder? _pageTransitions;
    Context ctx;
    if (body != null &&
        body is Map &&
        body['at'] != null &&
        body['path'] != null &&
        body['pathParams'] != null &&
        body['isDirectly'] != null) {
      ctx = Context.fromJson(body);
    } else {
      ctx = Context(
        path,
        body: body,
        isDirectly: true,
      );
    }
    WidgetBuilder? builder;
    NavigatorRoute? handler = RRouter._register.match(ctx.uri);
    if (handler != null) {
      final result = await handler(ctx);
      if (result is WidgetBuilder) {
        builder = result;
      } else if (result is Redirect) {
        return parseRouteInformation(
            RouteInformation(location: result.path, state: body));
      }
      _pageTransitions = handler.defaultPageTransaction;
    }
    _pageTransitions ??= RRouter._defaultTransitionBuilder;

    builder ??=
        (BuildContext context) => RRouter._errorPage.notFoundPage(context, ctx);
    return SynchronousFuture(
        RRouter._pageNamed(ctx, builder, _pageTransitions));
  }

  @override
  RouteInformation? restoreRouteInformation(Page<dynamic> configuration) {
    if (configuration.name == null) return null;
    return RouteInformation(
        location: configuration.name, state: configuration.arguments);
  }
}
