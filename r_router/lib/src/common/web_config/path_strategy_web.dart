import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void setUrlPathStrategy(bool isUsePath) {
  setUrlStrategy(isUsePath ? PathUrlStrategy() : HashUrlStrategy());
}
