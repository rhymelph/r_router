// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:flutter/material.dart';

/// Delegate for [showSearch] to define the content of the search page.
///
/// The search page always shows an [AppBar] at the top where users can
/// enter their search queries. The buttons shown before and after the search
/// query text field can be customized via [SearchDelegate.leading] and
/// [SearchDelegate.actions].
///
/// The body below the [AppBar] can either show suggested queries (returned by
/// [SearchDelegate.buildSuggestions]) or - once the user submits a search  - the
/// results of the search as returned by [SearchDelegate.buildResults].
///
/// [SearchDelegate.query] always contains the current query entered by the user
/// and should be used to build the suggestions and results.
///
/// The results can be brought on screen by calling [SearchDelegate.showResults]
/// and you can go back to showing the suggestions by calling
/// [SearchDelegate.showSuggestions].
///
/// Once the user has selected a search result, [SearchDelegate.close] should be
/// called to remove the search page from the top of the navigation stack and
/// to notify the caller of [showSearch] about the selected search result.
///
/// A given [SearchDelegate] can only be associated with one active [showSearch]
/// call. Call [SearchDelegate.close] before re-using the same delegate instance
/// for another [showSearch] call.
abstract class SearchDelegate<T> {
  /// Constructor to be called by subclasses which may specify [searchFieldLabel], [keyboardType] and/or
  /// [textInputAction].
  ///
  /// {@tool sample}
  /// ```dart
  /// class CustomSearchHintDelegate extends SearchDelegate {
  ///   CustomSearchHintDelegate({
  ///     String hintText,
  ///   }) : super(
  ///     searchFieldLabel: hintText,
  ///     keyboardType: TextInputType.text,
  ///     textInputAction: TextInputAction.search,
  ///   );
  ///
  ///   @override
  ///   Widget buildLeading(BuildContext context) => Text("leading");
  ///
  ///   @override
  ///   Widget buildSuggestions(BuildContext context) => Text("suggestions");
  ///
  ///   @override
  ///   Widget buildResults(BuildContext context) => Text('results');
  ///
  ///   @override
  ///   List<Widget> buildActions(BuildContext context) => [];
  /// }
  /// ```
  /// {@end-tool}
  SearchDelegate({
    this.searchFieldLabel,
    this.keyboardType,
    this.textInputAction = TextInputAction.search,
  });

  /// Suggestions shown in the body of the search page while the user types a
  /// query into the search field.
  ///
  /// The delegate method is called whenever the content of [query] changes.
  /// The suggestions should be based on the current [query] string. If the query
  /// string is empty, it is good practice to show suggested queries based on
  /// past queries or the current context.
  ///
  /// Usually, this method will return a [ListView] with one [ListTile] per
  /// suggestion. When [ListTile.onTap] is called, [query] should be updated
  /// with the corresponding suggestion and the results page should be shown
  /// by calling [showResults].
  Widget buildSuggestions(BuildContext context);

  /// The results shown after the user submits a search from the search page.
  ///
  /// The current value of [query] can be used to determine what the user
  /// searched for.
  ///
  /// This method might be applied more than once to the same query.
  /// If your [buildResults] method is computationally expensive, you may want
  /// to cache the search results for one or more queries.
  ///
  /// Typically, this method returns a [ListView] with the search results.
  /// When the user taps on a particular search result, [close] should be called
  /// with the selected result as argument. This will close the search page and
  /// communicate the result back to the initial caller of [showSearch].
  Widget buildResults(BuildContext context);

  /// A widget to display before the current query in the [AppBar].
  ///
  /// Typically an [IconButton] configured with a [BackButtonIcon] that exits
  /// the search with [close]. One can also use an [AnimatedIcon] driven by
  /// [transitionAnimation], which animates from e.g. a hamburger menu to the
  /// back button as the search overlay fades in.
  ///
  /// Returns null if no widget should be shown.
  ///
  /// See also:
  ///
  ///  * [AppBar.leading], the intended use for the return value of this method.
  Widget buildLeading(BuildContext context);

  /// Widgets to display after the search query in the [AppBar].
  ///
  /// If the [query] is not empty, this should typically contain a button to
  /// clear the query and show the suggestions again (via [showSuggestions]) if
  /// the results are currently shown.
  ///
  /// Returns null if no widget should be shown
  ///
  /// See also:
  ///
  ///  * [AppBar.actions], the intended use for the return value of this method.
  List<Widget> buildActions(BuildContext context);

  /// The theme used to style the [AppBar].
  ///
  /// By default, a white theme is used.
  ///
  /// See also:
  ///
  ///  * [AppBar.backgroundColor], which is set to [ThemeData.primaryColor].
  ///  * [AppBar.iconTheme], which is set to [ThemeData.primaryIconTheme].
  ///  * [AppBar.titleTextStyle], which is set to [ThemeData.primaryTextTheme].
  ///  * [AppBar.systemOverlayStyle].
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      primaryColor: Colors.white,
      primaryIconTheme: theme.primaryIconTheme.copyWith(color: Colors.grey),
      primaryTextTheme: theme.textTheme,
    );
  }

  /// The current query string shown in the [AppBar].
  ///
  /// The user manipulates this string via the keyboard.
  ///
  /// If the user taps on a suggestion provided by [buildSuggestions] this
  /// string should be updated to that suggestion via the setter.
  String get query => _queryTextController.text;

  set query(String value) {
    _queryTextController.text = value;
  }

  /// Transition from the suggestions returned by [buildSuggestions] to the
  /// [query] results returned by [buildResults].
  ///
  /// If the user taps on a suggestion provided by [buildSuggestions] the
  /// screen should typically transition to the page showing the search
  /// results for the suggested query. This transition can be triggered
  /// by calling this method.
  ///
  /// See also:
  ///
  ///  * [showSuggestions] to show the search suggestions again.
  void showResults(BuildContext context) {
    _focusNode?.unfocus();
    currentBody = SearchBody.results;
  }

  /// Transition from showing the results returned by [buildResults] to showing
  /// the suggestions returned by [buildSuggestions].
  ///
  /// Calling this method will also put the input focus back into the search
  /// field of the [AppBar].
  ///
  /// If the results are currently shown this method can be used to go back
  /// to showing the search suggestions.
  ///
  /// See also:
  ///
  ///  * [showResults] to show the search results.
  void showSuggestions(BuildContext context) {
    assert(_focusNode != null,
        '_focusNode must be set by route before showSuggestions is called.');
    _focusNode!.requestFocus();
    currentBody = SearchBody.suggestions;
  }

  /// Closes the search page and returns to the underlying route.
  ///
  /// The value provided for `result` is used as the return value of the call
  /// to [showSearch] that launched the search initially.
  void close(BuildContext context, T result) {
    currentBody = null;
    _focusNode?.unfocus();
    Navigator.of(context)
      ..popUntil((Route<dynamic> route) => route == _route)
      ..pop(result);
  }

  /// The hint text that is shown in the search field when it is empty.
  ///
  /// If this value is set to null, the value of MaterialLocalizations.of(context).searchFieldLabel will be used instead.
  final String? searchFieldLabel;

  /// The type of action button to use for the keyboard.
  ///
  /// Defaults to the default value specified in [TextField].
  final TextInputType? keyboardType;

  /// The text input action configuring the soft keyboard to a particular action
  /// button.
  ///
  /// Defaults to [TextInputAction.search].
  final TextInputAction textInputAction;

  /// [Animation] triggered when the search pages fades in or out.
  ///
  /// This animation is commonly used to animate [AnimatedIcon]s of
  /// [IconButton]s returned by [buildLeading] or [buildActions]. It can also be
  /// used to animate [IconButton]s contained within the route below the search
  /// page.
  Animation<double> get transitionAnimation => _proxyAnimation;

  // The focus node to use for manipulating focus on the search page. This is
  // managed, owned, and set by the _SearchPageRoute using this delegate.
  FocusNode? _focusNode;

  final TextEditingController _queryTextController = TextEditingController();

  final ProxyAnimation _proxyAnimation =
      ProxyAnimation(kAlwaysDismissedAnimation);

  final ValueNotifier<SearchBody?> _currentBodyNotifier =
      ValueNotifier<SearchBody?>(null);

  SearchBody? get currentBody => _currentBodyNotifier.value;

  set currentBody(SearchBody? value) {
    _currentBodyNotifier.value = value;
  }

  SearchPageRouteMixin<T>? _route;
}

/// Describes the body that is currently shown under the [AppBar] in the
/// search page.
enum SearchBody {
  /// Suggested queries are shown in the body.
  ///
  /// The suggested queries are generated by [SearchDelegate.buildSuggestions].
  suggestions,

  /// Search results are currently shown in the body.
  ///
  /// The search results are generated by [SearchDelegate.buildResults].
  results,
}

mixin SearchPageRouteMixin<T> on PageRoute<T> {
  late SearchDelegate<T> delegate;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  @override
  Animation<double> createAnimation() {
    final Animation<double> animation = super.createAnimation();
    delegate._proxyAnimation.parent = animation;
    return animation;
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return _SearchPage<T>(
      delegate: delegate,
      animation: animation,
    );
  }

  @override
  void didComplete(T? result) {
    super.didComplete(result);
    delegate._route = null;
    delegate.currentBody = null;
  }
}

class SearchPageRoute<T> extends PageRoute<T> with SearchPageRouteMixin<T> {
  SearchPageRoute({
    required this.delegate,
  }) {
    assert(
      delegate._route == null,
      'The ${delegate.runtimeType} instance is currently used by another active '
      'search. Please close that search by calling close() on the SearchDelegate '
      'before openening another search with the same delegate instance.',
    );
    delegate._route = this;
  }

  final SearchDelegate<T> delegate;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  bool get maintainState => false;
}

class _SearchPage<T> extends StatefulWidget {
  const _SearchPage({
    this.delegate,
    this.animation,
  });

  final SearchDelegate<T>? delegate;
  final Animation<double>? animation;

  @override
  State<StatefulWidget> createState() => _SearchPageState<T>();
}

class _SearchPageState<T> extends State<_SearchPage<T>> {
  // This node is owned, but not hosted by, the search page. Hosting is done by
  // the text field.
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.delegate!._queryTextController.addListener(_onQueryChanged);
    widget.animation!.addStatusListener(_onAnimationStatusChanged);
    widget.delegate!._currentBodyNotifier.addListener(_onSearchBodyChanged);
    focusNode.addListener(_onFocusChanged);
    widget.delegate!._focusNode = focusNode;
  }

  @override
  void dispose() {
    super.dispose();
    widget.delegate!._queryTextController.removeListener(_onQueryChanged);
    widget.animation!.removeStatusListener(_onAnimationStatusChanged);
    widget.delegate!._currentBodyNotifier.removeListener(_onSearchBodyChanged);
    widget.delegate!._focusNode = null;
    focusNode.dispose();
  }

  void _onAnimationStatusChanged(AnimationStatus status) {
    if (status != AnimationStatus.completed) {
      return;
    }
    widget.animation!.removeStatusListener(_onAnimationStatusChanged);
    if (widget.delegate!.currentBody == SearchBody.suggestions) {
      focusNode.requestFocus();
    }
  }

  @override
  void didUpdateWidget(_SearchPage<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.delegate != oldWidget.delegate) {
      oldWidget.delegate!._queryTextController.removeListener(_onQueryChanged);
      widget.delegate!._queryTextController.addListener(_onQueryChanged);
      oldWidget.delegate!._currentBodyNotifier
          .removeListener(_onSearchBodyChanged);
      widget.delegate!._currentBodyNotifier.addListener(_onSearchBodyChanged);
      oldWidget.delegate!._focusNode = null;
      widget.delegate!._focusNode = focusNode;
    }
  }

  void _onFocusChanged() {
    if (focusNode.hasFocus &&
        widget.delegate!.currentBody != SearchBody.suggestions) {
      widget.delegate!.showSuggestions(context);
    }
  }

  void _onQueryChanged() {
    setState(() {
      // rebuild ourselves because query changed.
    });
  }

  void _onSearchBodyChanged() {
    setState(() {
      // rebuild ourselves because search body changed.
    });
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    final ThemeData theme = widget.delegate!.appBarTheme(context);
    final String searchFieldLabel = widget.delegate!.searchFieldLabel ??
        MaterialLocalizations.of(context).searchFieldLabel;
    Widget? body;
    switch (widget.delegate!.currentBody!) {
      case SearchBody.suggestions:
        body = KeyedSubtree(
          key: const ValueKey<SearchBody>(SearchBody.suggestions),
          child: widget.delegate!.buildSuggestions(context),
        );
        break;
      case SearchBody.results:
        body = KeyedSubtree(
          key: const ValueKey<SearchBody>(SearchBody.results),
          child: widget.delegate!.buildResults(context),
        );
        break;
    }
    String? routeName;
    switch (theme.platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        routeName = '';
        break;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        routeName = searchFieldLabel;
    }

    return Semantics(
      explicitChildNodes: true,
      scopesRoute: true,
      namesRoute: true,
      label: routeName,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: theme.primaryColor,
          iconTheme: theme.primaryIconTheme,
          leading: widget.delegate!.buildLeading(context),
          title: TextField(
            controller: widget.delegate!._queryTextController,
            focusNode: focusNode,
            style: theme.textTheme.titleLarge,
            textInputAction: widget.delegate!.textInputAction,
            keyboardType: widget.delegate!.keyboardType,
            onSubmitted: (String _) {
              widget.delegate!.showResults(context);
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: searchFieldLabel,
              hintStyle: theme.inputDecorationTheme.hintStyle,
            ),
          ),
          actions: widget.delegate!.buildActions(context),
          toolbarTextStyle: theme.primaryTextTheme.bodyMedium,
          titleTextStyle: theme.primaryTextTheme.titleLarge,
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: body,
        ),
      ),
    );
  }
}
