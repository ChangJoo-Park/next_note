import 'package:flutter_test/flutter_test.dart';
import 'package:next_page/store/store.dart' as store;

void main() async {
  group('description', () {
    setUpAll(() async {
      await store.database();
    });

    tearDownAll(() async {
      await store.removeAllItems();
    });

    test('GET ITEMS', () {});
  });
}
