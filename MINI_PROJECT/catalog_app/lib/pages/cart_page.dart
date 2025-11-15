import 'package:catalog_app/core/store.dart';
import 'package:catalog_app/models/cart.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:go_router/go_router.dart';
import 'package:catalog_app/utils/routes.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.canvasColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: "Cart".text.make(),
      ),
      body: Column(
        children: [
          _CartList().p32().expand(),
          const Divider(),
          _CartTotal(),
        ],
      ),
    );
  }
}

class _CartTotal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          VxBuilder<MyStore>(
            mutations: const {
              RemoveItemMutation,
              AddMutation,
              DecreaseItemMutation
            },
            builder: (context, store, _) {
              return "\$${store.cart.totalPrice.toStringAsFixed(2)}"
                  .text
                  .xl5
                  .color(context.theme.colorScheme.secondary)
                  .make();
            },
          ),
          30.widthBox,
          ElevatedButton(
            onPressed: () {
              context.push(MyRoutes.checkoutRoute);
            },
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all(context.theme.colorScheme.primary),
            ),
            child: "Buy Now".text.white.make(),
          ).w40(context)
        ],
      ),
    );
  }
}

class _CartList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    VxState.watch(context,
        on: [RemoveItemMutation, AddMutation, DecreaseItemMutation]);

    final CartModel cart = (VxState.store as MyStore).cart;

    return cart.items.isEmpty
        ? "Nothing to show".text.xl3.makeCentered()
        : ListView.builder(
            itemCount: cart.items.length,
            itemBuilder: (context, index) {
              final item = cart.items[index];
              final quantity = cart.getQuantity(item.id);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.image,
                          width: 60,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (context, _, __) {
                            return Container(
                              width: 60,
                              height: 70,
                              color: context.canvasColor,
                              child: const Icon(Icons.image_not_supported),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Product Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "\$${item.price.toStringAsFixed(2)}",
                              style: TextStyle(
                                color: context.theme.colorScheme.secondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Quantity Controls
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        visualDensity: VisualDensity.compact,
                                        iconSize: 18.0,
                                        icon: const Icon(Icons.remove),
                                        onPressed: () =>
                                            DecreaseItemMutation(item),
                                        padding: const EdgeInsets.all(4),
                                        constraints: const BoxConstraints(
                                          minWidth: 32,
                                          minHeight: 32,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: Text(
                                          "$quantity",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        visualDensity: VisualDensity.compact,
                                        iconSize: 18.0,
                                        icon: const Icon(Icons.add),
                                        onPressed: () => AddMutation(item),
                                        padding: const EdgeInsets.all(4),
                                        constraints: const BoxConstraints(
                                          minWidth: 32,
                                          minHeight: 32,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                // Total Price
                                Text(
                                  "\$${(item.price * quantity).toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Delete Button
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        color: Colors.red.shade400,
                        onPressed: () => RemoveItemMutation(item),
                        tooltip: 'Remove item',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }
}
