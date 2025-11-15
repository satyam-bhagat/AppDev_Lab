import 'package:firebase_auth/firebase_auth.dart';
import 'package:catalog_app/core/store.dart';
import 'package:catalog_app/models/cart.dart';
import 'package:catalog_app/models/catalog.dart';
import 'package:catalog_app/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:catalog_app/utils/routes.dart';
import 'package:catalog_app/widgets/drawer.dart';
import 'package:catalog_app/widgets/home_widgets/catalog_header.dart';
import 'package:catalog_app/widgets/home_widgets/catalog_list.dart';
import 'package:catalog_app/widgets/searchbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final url = "https://fakestoreapi.com/products";
  bool _isLoading = true;
  String? _loadError;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    loadData();
    _loadUserOnRestart();
  }

  Future<void> _loadUserOnRestart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && (VxState.store as MyStore).role == 'guest') {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        LoadUserDataMutation(UserModel.fromFirestore(doc));
      }
    }
  }

  Future<void> loadData() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> decodedData = jsonDecode(response.body);

        final List<Item> products =
            decodedData.map((item) => Item.fromMap(item)).toList();

        if (mounted) {
          SetCatalogMutation(products);
        }
      } else {
        throw Exception(
            "Failed to load products (Status Code: ${response.statusCode})");
      }
    } catch (e) {
      Vx.log("Error loading data: $e");
      if (mounted) {
        setState(() {
          _loadError = "Could not load products. Please try again later.";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.canvasColor,
      appBar: AppBar(
        elevation: 0,
      ),
      drawer: const MyDrawer(),
      floatingActionButton: VxBuilder<MyStore>(
        mutations: const {
          AddMutation,
          RemoveItemMutation,
          DecreaseItemMutation
        },
        builder: (ctx, store, _) {
          if (store.role == 'guest') {
            return Container();
          }
          return FloatingActionButton(
            onPressed: () => context.push(MyRoutes.cartRoute),
            backgroundColor: context.theme.colorScheme.primary,
            child: const Icon(CupertinoIcons.cart, color: Colors.white),
          ).badge(
            color: Vx.red500,
            size: 22,
            count: store.cart.items.length,
            textStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          );
        },
      ),
      body: SafeArea(
        child: Container(
          padding: Vx.m32,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VxBuilder<MyStore>(
                mutations: const {LoadUserDataMutation, ClearUserDataMutation},
                builder: (context, store, status) {
                  final String role = store.role;
                  final String? name = store.user.displayName;
                  final String plan = store.plan;

                  if (role == "guest") {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        "Catalog App"
                            .text
                            .xl5
                            .bold
                            .color(context.theme.colorScheme.secondary)
                            .make(),
                        "Sign in for more features".text.xl.make(),
                      ],
                    );
                  }

                  if (role == "admin") {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        "Admin Panel".text.xl5.bold.red500.make(),
                        "Welcome, $name (Admin)".text.xl2.make(),
                      ],
                    );
                  }

                  if (role == "vip") {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        "VIP Catalog".text.xl5.bold.amber500.make(),
                        "Welcome, $name (VIP)".text.xl2.make(),
                      ],
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CatalogHeader(),
                      "Welcome, $name".text.xl.make().pOnly(top: 8),
                      if (plan.isNotEmpty)
                        _PlanSummary(
                          plan: plan,
                          onUpgrade: plan.toLowerCase() == 'premium'
                              ? null
                              : () => context.push(MyRoutes.vipRoute),
                          itemLimit: _maxItemsForPlan(plan, role),
                        ).pOnly(top: 16),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              SearchBarWidget(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              16.heightBox,
              Expanded(
                child: VxBuilder<MyStore>(
                  mutations: const {
                    LoadUserDataMutation,
                    ClearUserDataMutation
                  },
                  builder: (context, store, _) {
                    final plan = store.plan;
                    final maxItems = _maxItemsForPlan(plan, store.role);
                    return _buildContentArea(maxItems: maxItems);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int? _maxItemsForPlan(String plan, String role) {
    if (role == 'guest') {
      return 5;
    }
    switch (plan.toLowerCase()) {
      case 'free':
        return 5;
      case 'vip':
        return 10;
      case 'premium':
        return null;
      default:
        return 5;
    }
  }

  Widget _buildContentArea({int? maxItems}) {
    if (_isLoading) {
      return const CircularProgressIndicator().centered();
    }

    if (_loadError != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _loadError!.text.xl3.red500.center.make(),
          16.heightBox,
          ElevatedButton(
            onPressed: loadData,
            child: const Text("Try Again"),
          )
        ],
      ).centered();
    }

    if ((VxState.store as MyStore).catalog.items.isEmpty) {
      return "No products found".text.xl3.makeCentered();
    }

    return CatalogList(
      searchQuery: _searchQuery,
      maxItems: maxItems,
    );
  }
}

class _PlanSummary extends StatelessWidget {
  const _PlanSummary({
    required this.plan,
    required this.itemLimit,
    this.onUpgrade,
  });

  final String plan;
  final int? itemLimit;
  final VoidCallback? onUpgrade;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final normalized = plan.toLowerCase();
    final background = normalized == 'premium'
        ? Colors.deepPurple.withOpacity(0.1)
        : normalized == 'vip'
            ? Colors.amber.withOpacity(0.15)
            : theme.colorScheme.surfaceVariant;
    final accent = normalized == 'premium'
        ? Colors.deepPurple
        : normalized == 'vip'
            ? Colors.orange.shade800
            : theme.colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: accent.withOpacity(0.15),
            child: Icon(
              normalized == 'premium'
                  ? Icons.workspace_premium_outlined
                  : normalized == 'vip'
                      ? Icons.star
                      : Icons.lock_open_outlined,
              color: accent,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Plan: $plan',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  itemLimit == null
                      ? 'You can browse the full catalog.'
                      : 'Showing up to $itemLimit items from the catalog.',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.hintColor),
                ),
              ],
            ),
          ),
          if (onUpgrade != null)
            TextButton(
              onPressed: onUpgrade,
              child: const Text('Upgrade Plan'),
            ),
        ],
      ),
    );
  }
}
