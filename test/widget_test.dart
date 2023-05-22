// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:blackhole/Helpers/update.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('update check tests', () {
    test('compareVersion should return true if update is available', () {
      // Arrange: Set up the necessary variables and inputs
      const String currentVersion = '1.1.2';
      const String latestVerion = '1.1.3';

      final result = compareVersion(latestVerion, currentVersion);

      expect(result, equals(true));
    });

    test('compareVersion should return false if update is not available', () {
      // Arrange: Set up the necessary variables and inputs
      const String currentVersion = '1.1.2';
      const String latestVerion = '1.1.2';

      final result = compareVersion(latestVerion, currentVersion);

      expect(result, equals(false));
    });
  });
}
