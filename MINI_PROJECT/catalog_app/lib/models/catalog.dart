import 'package:catalog_app/core/store.dart';
import 'package:velocity_x/velocity_x.dart';

class CatalogModel {
  List<Item> items = [];
  Item getById(int id) => items.firstWhere(
        (element) => element.id == id,
        orElse: () => Item.empty(),
      );
  Item getByPosition(int pos) => items[pos];
}

class Item {
  final int id;
  final String name;
  final String desc;
  final num price;
  final String image;
  final String category;
  final bool isPremium; // For VIP Gating

  const Item({
    required this.id,
    required this.name,
    required this.desc,
    required this.price,
    required this.image,
    this.category = 'General',
    this.isPremium = false, // Default to false
  });

  factory Item.empty() => const Item(
        id: 0,
        name: '',
        desc: '',
        price: 0,
        image: '',
      );

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'] as int? ?? 0,
      name: map['title'] as String? ?? 'No Title',
      desc: map['description'] as String? ?? 'No Description',
      price: map['price'] as num? ?? 0,
      image: map['image'] as String? ?? 'https://via.placeholder.com/150',
      category: map['category'] as String? ?? 'General',
      isPremium: map['premium'] as bool? ?? false,
    );
  }
}

// --- SetCatalogMutation BELONGS HERE ---
class SetCatalogMutation extends VxMutation<MyStore> {
  final List<Item> items;
  SetCatalogMutation(this.items);

  @override
  perform() {
    store!.catalog.items = items;
  }
}
