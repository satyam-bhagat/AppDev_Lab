import 'package:catalog_app/core/store.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:catalog_app/utils/routes.dart';
import 'package:velocity_x/velocity_x.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  // Helper method to get plan icon and color
  Map<String, dynamic> _getPlanDetails(String plan) {
    final planLower = plan.toLowerCase();
    switch (planLower) {
      case 'premium':
        return {
          'icon': Icons.workspace_premium,
          'color': Colors.deepPurple.shade300,
          'label': 'Premium',
        };
      case 'vip':
        return {
          'icon': Icons.star_rounded,
          'color': Colors.amber,
          'label': 'VIP',
        };
      case 'free':
      default:
        return {
          'icon': Icons.card_membership,
          'color': Colors.grey.shade400,
          'label': 'Free',
        };
    }
  }

  // Helper method to get plan button text
  String _getPlanButtonText(String plan) {
    final planLower = plan.toLowerCase();
    if (planLower == 'premium') {
      return 'Manage Plan';
    } else if (planLower == 'vip') {
      return 'Upgrade to Premium';
    } else {
      return 'Upgrade Plan';
    }
  }

  @override
  Widget build(BuildContext context) {
    final photoUrl = FirebaseAuth.instance.currentUser?.photoURL;

    return Drawer(
      child: VxBuilder<MyStore>(
        mutations: const {LoadUserDataMutation, ClearUserDataMutation},
        builder: (context, store, status) {
          final user = store.user;
          final isLoggedIn = store.isLoggedIn;
          final isAdmin = store.role == 'admin';
          final currentPlan = store.plan;
          final planDetails = _getPlanDetails(currentPlan);

          return Container(
            color: Colors.deepPurple,
            child: SafeArea(
              bottom: true,
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        if (isLoggedIn)
                          UserAccountsDrawerHeader(
                            margin: EdgeInsets.zero,
                            accountName: Text(user.displayName ?? "User"),
                            accountEmail: Text(user.email ?? "No Email"),
                            currentAccountPicture: CircleAvatar(
                              backgroundImage:
                                  (photoUrl != null && photoUrl.isNotEmpty)
                                      ? NetworkImage(photoUrl)
                                      : null,
                              child: (photoUrl == null || photoUrl.isEmpty)
                                  ? const Icon(Icons.person,
                                      color: Colors.white)
                                  : null,
                            ),
                          )
                        else
                          UserAccountsDrawerHeader(
                            margin: EdgeInsets.zero,
                            accountName: const Text("Welcome, Guest!"),
                            accountEmail: const Text("Sign in to unlock plans"),
                            currentAccountPicture: const CircleAvatar(
                              backgroundColor: Colors.white24,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                          ),
                        ListTile(
                          leading: const Icon(CupertinoIcons.home,
                              color: Colors.white),
                          title: "Home".text.white.make(),
                          onTap: () {
                            context.pop();
                            context.go(MyRoutes.homeRoute);
                          },
                        ),
                        ListTile(
                          leading: const Icon(CupertinoIcons.profile_circled,
                              color: Colors.white),
                          title: (isLoggedIn
                                  ? "Profile"
                                  : "Profile (Sign in)")
                              .text
                              .white
                              .make(),
                          onTap: () {
                            context.pop();
                            if (isLoggedIn) {
                              context.push(MyRoutes.profileRoute);
                            } else {
                              context.go(MyRoutes.loginRoute);
                            }
                          },
                        ),
                        if (isLoggedIn && isAdmin)
                          ListTile(
                            leading: const Icon(Icons.admin_panel_settings,
                                color: Colors.redAccent),
                            title: "Admin Panel"
                                .text
                                .color(Colors.redAccent)
                                .bold
                                .make(),
                            onTap: () {
                              context.pop();
                              context.push(MyRoutes.adminPanelRoute);
                            },
                          ),
                        if (!isLoggedIn)
                          ListTile(
                            leading:
                                const Icon(Icons.login, color: Colors.white),
                            title: "Sign In".text.white.make(),
                            onTap: () {
                              context.pop();
                              context.go(MyRoutes.loginRoute);
                            },
                          ),
                        if (isLoggedIn)
                          ListTile(
                            leading:
                                const Icon(Icons.logout, color: Colors.white),
                            title: "Logout".text.white.make(),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      "Successfully logged out".text.make(),
                                  backgroundColor: Colors.green,
                                ),
                              );

                              ClearUserDataMutation();
                              FirebaseAuth.instance.signOut();
                              context.pop();
                            },
                          )
                      ],
                    ),
                  ),
                  // Current Plan Display & Upgrade Section
                  if (isLoggedIn) ...[
                    const Divider(color: Colors.white24, thickness: 1),
                    // Current Plan Badge
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: planDetails['color'],
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            planDetails['icon'],
                            color: planDetails['color'],
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                "Current Plan"
                                    .text
                                    .color(Colors.white70)
                                    .size(12)
                                    .make(),
                                (planDetails['label'] as String)
                                    .text
                                    .color(Colors.white)
                                    .bold
                                    .size(16)
                                    .make(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Plan Management Button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.pop();
                          context.push(MyRoutes.vipRoute);
                        },
                        icon: Icon(
                          currentPlan.toLowerCase() == 'premium'
                              ? Icons.settings
                              : Icons.arrow_upward,
                          size: 18,
                        ),
                        label: Text(_getPlanButtonText(currentPlan)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: planDetails['color'],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 4,
                        ),
                      ),
                    ),
                  ] else ...[
                    const Divider(color: Colors.white24, thickness: 1),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: OutlinedButton.icon(
                        onPressed: () {
                          context.pop();
                          context.go(MyRoutes.loginRoute);
                        },
                        icon: const Icon(Icons.login, size: 18),
                        label: const Text('Sign In to Unlock Plans'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white70),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
