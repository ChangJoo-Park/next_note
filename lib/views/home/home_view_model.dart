import 'package:next_page/core/base/base_view_model.dart';
import 'package:next_page/models/item.dart';

class HomeViewModel extends BaseViewModel {
  ItemProvider _itemProvider = ItemProvider();

  List<Item> _items = [];
  Item _currentItem;
  String _itemStatus;

  HomeViewModel({List<Item> items, Item currentItem}) {
    this._items = items;
    this._currentItem = currentItem;
  }

  ItemProvider get itemProvider => this._itemProvider;

  Item get currentItem => this._currentItem;
  set currentItem(Item value) {
    this._currentItem = value;
    notifyListeners();
  }

  String get itemStatus => this._itemStatus;
  set itemStatus(String value) {
    this._itemStatus = value;
    notifyListeners();
  }

  List<Item> get items => this._items;
  set items(List<Item> value) {
    this._items = value;
    notifyListeners();
  }

  createNewItem() async {
    _currentItem = await _itemProvider.create(Item());
    _itemStatus = null;
    await loadItems();
    notifyListeners();
  }

  Item get firstItem => this._items.first;

  Future<int> updateItem(Item item) async {
    int id = await _itemProvider.update(item);
    await loadItems();
    notifyListeners();
    return id;
  }

  loadItems() async {
    items = await itemProvider.getItems();
    notifyListeners();
  }
}
