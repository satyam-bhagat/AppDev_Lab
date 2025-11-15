import 'package:catalog_app/core/store.dart';
import 'package:catalog_app/models/catalog.dart';
import 'package:velocity_x/velocity_x.dart';

class CartModel {
  late CatalogModel _catalog;

  // Use a Map to store { item_id: quantity }
  final Map<int, int> _itemIds = {};

  CatalogModel get catalog => _catalog;

  set catalog(CatalogModel newCatalog) {
    _catalog = newCatalog;
  }

  // Get items by mapping IDs (keys) from the map
  List<Item> get items =>
      _itemIds.keys.map((id) => _catalog.getById(id)).toList();

  // Calculate total price based on quantity
  num get totalPrice {
    num total = 0;
    _itemIds.forEach((itemId, quantity) {
      final item = _catalog.getById(itemId);
      total += item.price * quantity;
    });
    return total;
  }

  // Helper function to get the quantity for a specific item
  int getQuantity(int id) {
    return _itemIds[id] ?? 0;
  }
}

// Increments quantity or adds item with quantity 1
class AddMutation extends VxMutation<MyStore> {
  final Item item;
  AddMutation(this.item);

  @override
  perform() {
    store?.cart._itemIds
        .update(item.id, (value) => value + 1, ifAbsent: () => 1);
  }
}

// New mutation to decrease quantity by 1
class DecreaseItemMutation extends VxMutation<MyStore> {
  final Item item;
  DecreaseItemMutation(this.item);

  @override
  perform() {
    final cart = store!.cart;
    if (cart._itemIds.containsKey(item.id)) {
      if (cart._itemIds[item.id]! > 1) {
        // If quantity > 1, just decrease it
        cart._itemIds[item.id] = cart._itemIds[item.id]! - 1;
      } else {
        // If quantity is 1, remove the item
        cart._itemIds.remove(item.id);
      }
    }
  }
}

// This mutation removes the entire item line, regardless of quantity.
class RemoveItemMutation extends VxMutation<MyStore> {
  final Item item;
  RemoveItemMutation(this.item);

  @override
  perform() {
    store?.cart._itemIds.remove(item.id);
  }
}
