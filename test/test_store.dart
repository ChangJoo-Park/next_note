import 'package:flutter_test/flutter_test.dart';
import 'package:next_page/store/store.dart' as store;
import 'package:dotenv/dotenv.dart' show load, env;

void main() async {
  load('test.env');

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
