import 'package:catalog_app/core/store.dart';
import 'package:catalog_app/models/cart.dart';
import 'package:catalog_app/models/catalog.dart';
import 'package:catalog_app/utils/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:velocity_x/velocity_x.dart';

class AddToCart extends StatelessWidget {
  final Item catalog;
  final bool compact;
  const AddToCart({super.key, required this.catalog, this.compact = false});

  void _showGuestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Sign In Required"),
        content: const Text(
            "Please sign in or create an account to add items to your cart."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go(MyRoutes.loginRoute);
            },
            child: const Text("Sign In"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    VxState.watch(context,
        on: [AddMutation, RemoveItemMutation, DecreaseItemMutation]);

    final MyStore store = VxState.store as MyStore;

    if (store.role == 'guest') {
      return SizedBox(
        height: 32,
        child: ElevatedButton(
          onPressed: () {
            _showGuestDialog(context);
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.grey),
            shape: MaterialStateProperty.all(const StadiumBorder()),
            padding: MaterialStateProperty.all(
              compact ? const EdgeInsets.symmetric(horizontal: 6) : const EdgeInsets.symmetric(horizontal: 10),
            ),
            minimumSize: MaterialStateProperty.all(
              compact ? const Size(40, 32) : const Size(80, 32),
            ),
          ),
          child: const Icon(CupertinoIcons.cart_badge_plus, color: Colors.white),
        ),
      );
    }

    final int quantity = store.cart.getQuantity(catalog.id);
    final bool isInCart = quantity > 0;

    return SizedBox(
      height: 32,
      child: ElevatedButton(
        onPressed: () {
          AddMutation(catalog);
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
            context.theme.colorScheme.primary,
          ),
          shape: MaterialStateProperty.all(const StadiumBorder()),
          padding: MaterialStateProperty.all(
            compact ? const EdgeInsets.symmetric(horizontal: 6) : const EdgeInsets.symmetric(horizontal: 10),
          ),
          minimumSize: MaterialStateProperty.all(
            compact ? const Size(40, 32) : const Size(80, 32),
          ),
        ),
        child: compact
            ? const Icon(CupertinoIcons.cart_badge_plus, color: Colors.white)
            : (isInCart
                ? "$quantity in cart".text.white.make()
                : const Icon(CupertinoIcons.cart_badge_plus, color: Colors.white)),
      ),
    );
  }
}
