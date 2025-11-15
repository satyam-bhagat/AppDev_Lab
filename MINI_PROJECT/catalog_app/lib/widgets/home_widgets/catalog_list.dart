import 'package:catalog_app/core/store.dart';
import 'package:catalog_app/models/catalog.dart';
import 'package:catalog_app/utils/routes.dart';
import 'package:catalog_app/widgets/home_widgets/add_to_cart.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:go_router/go_router.dart';

class CatalogList extends StatelessWidget {
  final String searchQuery;
  final int? maxItems;
  const CatalogList({super.key, this.searchQuery = "", this.maxItems});

  @override
  Widget build(BuildContext context) {
    final MyStore store = VxState.store as MyStore;

    List<Item> items = store.catalog.items;
    if (searchQuery.isNotEmpty) {
      items = items
          .where((item) =>
              item.name.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    if (items.isEmpty) {
      return "No products match your search.".text.xl2.makeCentered();
    }

    if (maxItems != null && items.length > maxItems!) {
      items = items.take(maxItems!).toList();
    }

    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 1100
        ? 4
        : width > 800
            ? 3
            : 2;

    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 18,
        crossAxisSpacing: 18,
        childAspectRatio: 0.64,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final catalog = items[index];
        return _CatalogCard(catalog: catalog);
      },
    );
  }
}

class _CatalogCard extends StatelessWidget {
  const _CatalogCard({required this.catalog});

  final Item catalog;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = VxState.store as MyStore;
    final bool isPremiumItem = catalog.isPremium;
    final bool canAccess = !isPremiumItem || store.hasPaidPlan;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          if (canAccess) {
            context.push(MyRoutes.homeDetailsRoute, extra: catalog);
          } else {
            context.push(MyRoutes.vipRoute);
          }
        },
        child: Ink(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: Hero(
                    tag: 'catalog-${catalog.id}',
                    child: Image.network(
                      catalog.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, _, __) {
                        return Container(
                          color: theme.colorScheme.surfaceVariant,
                          alignment: Alignment.center,
                          child: const Icon(Icons.image_not_supported_outlined),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            catalog.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        if (isPremiumItem)
                          const Icon(Icons.workspace_premium,
                              color: Colors.amber, size: 18),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      catalog.desc,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.hintColor),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "\$${catalog.price}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (canAccess)
                          AddToCart(catalog: catalog, compact: true)
                        else
                          SizedBox(
                            height: 36,
                            child: OutlinedButton(
                              onPressed: () => context.push(MyRoutes.vipRoute),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.amber.shade800,
                                side: BorderSide(color: Colors.amber.shade400),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                minimumSize: const Size(70, 36),
                              ),
                              child: const Text('Upgrade'),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
