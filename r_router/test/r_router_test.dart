import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:r_router/r_router.dart';

void main() {
  test('adds one to input values', () {
    Context context = Context('/home.dart',body: null);
    String result = json.encode(context);
    print(result);
//    final calculator = Calculator();
//    expect(calculator.addOne(2), 3);
//    expect(calculator.addOne(-7), -6);
//    expect(calculator.addOne(0), 1);
//    expect(() => calculator.addOne(null), throwsNoSuchMethodError);
  });
}
