import 'package:catalog_app/models/cart.dart';
import 'package:catalog_app/models/catalog.dart';
import 'package:catalog_app/models/user.dart';
import 'package:flutter/widgets.dart'; // Use widgets.dart or foundation.dart
import 'package:velocity_x/velocity_x.dart';
// Note: material.dart and cupertino.dart are not needed here

// --- THIS IS THE FIX ---
// 1. Create a subclass of ChangeNotifier
class AppChangeNotifier extends ChangeNotifier {
  // 2. Create a public method that calls the protected 'notifyListeners'
  void notify() {
    notifyListeners();
  }
}
// --- END OF FIX ---

class MyStore extends VxStore {
  late CatalogModel catalog;
  late CartModel cart;

  UserModel user = UserModel.guest();
  String get plan => user.plan;
  String get role => user.role;
  bool get isPremium => user.isPremium;
  bool get hasPaidPlan => user.hasPaidPlan;
  bool get isLoggedIn => user.role != 'guest';

  // 3. Use our new AppChangeNotifier
  final AppChangeNotifier authListenable = AppChangeNotifier();

  MyStore() {
    catalog = CatalogModel();
    cart = CartModel();
    cart.catalog = catalog;
  }
}

// --- USER MUTATIONS ---
class LoadUserDataMutation extends VxMutation<MyStore> {
  final UserModel user;
  LoadUserDataMutation(this.user);

  @override
  perform() {
    store!.user = user;
    // 4. Call our new public 'notify' method
    store!.authListenable.notify();
  }
}

class UpdateUserRole extends VxMutation<MyStore> {
  final String newRole;
  UpdateUserRole(this.newRole);

  @override
  perform() {
    store!.user = store!.user.copyWith(role: newRole);
    // 4. Call our new public 'notify' method
    store!.authListenable.notify();
  }
}

class UpdatePremiumStatus extends VxMutation<MyStore> {
  final bool isPremium;
  UpdatePremiumStatus(this.isPremium);

  @override
  perform() {
    final updatedPlan = isPremium ? 'Premium' : 'Free';
    store!.user = store!.user.copyWith(plan: updatedPlan);
    // 4. Call our new public 'notify' method
    store!.authListenable.notify();
  }
}

class ClearUserDataMutation extends VxMutation<MyStore> {
  @override
  perform() {
    store!.user = UserModel.guest();
    // 4. Call our new public 'notify' method
    store!.authListenable.notify();
  }
}
