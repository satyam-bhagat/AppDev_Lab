import 'package:catalog_app/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class AdminPanelPage extends StatelessWidget {
  const AdminPanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // Four tabs: Dashboard, Users, Products, Settings
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Admin Panel"),
          backgroundColor: Colors.red.shade700,
        ),
        // StreamBuilder fetches all user data ONCE and passes it to the tabs
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No users found."));
            }

            // Process all user data
            final allUsers = snapshot.data!.docs
                .map((doc) => UserModel.fromFirestore(doc))
                .toList();

            // Calculate dashboard stats
            final totalUsers = allUsers.length;
            final vipUsers = allUsers.where((u) => u.hasPaidPlan).length;
            final adminUsers = allUsers.where((u) => u.role == 'admin').length;

            return TabBarView(
              children: [
                // --- Tab 1: Dashboard ---
                _buildDashboardTab(context, totalUsers, vipUsers, adminUsers),

                // --- Tab 2: User Management ---
                _UserManagementTab(allUsers: allUsers),

                // --- Tab 3: Product Management (Placeholder) ---
                _buildPlaceholderTab(
                    icon: Icons.shopping_bag,
                    title: "Product Management",
                    message:
                        "Future home for editing, adding, and managing all catalog items."),

                // --- Tab 4: App Settings (Placeholder) ---
                _buildPlaceholderTab(
                    icon: Icons.settings,
                    title: "App Settings",
                    message:
                        "Future home for managing feature flags and the admin secret code."),
              ],
            );
          },
        ),
        bottomNavigationBar: const TabBar(
          tabs: [
            Tab(icon: Icon(Icons.dashboard), text: "Dashboard"),
            Tab(icon: Icon(Icons.people), text: "Users"),
            Tab(icon: Icon(Icons.store), text: "Products"),
            Tab(icon: Icon(Icons.settings), text: "Settings"),
          ],
        ),
      ),
    );
  }

  // --- Dashboard Tab UI ---
  Widget _buildDashboardTab(
      BuildContext context, int totalUsers, int vipUsers, int adminUsers) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          "App Overview".text.xl3.bold.make(),
          16.heightBox,
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _InfoCard(
                title: "Total Users",
                value: totalUsers.toString(),
                icon: Icons.people_alt,
                color: Colors.blue,
              ),
              _InfoCard(
                title: "Paid Members",
                value: vipUsers.toString(),
                icon: Icons.star,
                color: Colors.amber,
              ),
              _InfoCard(
                title: "Admins",
                value: adminUsers.toString(),
                icon: Icons.security,
                color: Colors.red,
              ),
            ],
          ),
          // You could add more charts or stats here
        ],
      ),
    );
  }

  // --- Placeholder Tab UI ---
  Widget _buildPlaceholderTab(
      {required IconData icon,
      required String title,
      required String message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey.shade400),
          16.heightBox,
          title.text.xl3.bold.make(),
          8.heightBox,
          message.text.gray500.center.make().px32(),
        ],
      ),
    );
  }
}

// --- User Management Tab (Stateful for Search) ---
class _UserManagementTab extends StatefulWidget {
  final List<UserModel> allUsers;
  const _UserManagementTab({required this.allUsers});

  @override
  State<_UserManagementTab> createState() => _UserManagementTabState();
}

class _UserManagementTabState extends State<_UserManagementTab> {
  String _searchQuery = "";

  Future<void> _updateUserRole(String uid, String newRole) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'role': newRole});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("User role updated."), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _updatePlan(String uid, String newPlan) async {
    try {
      final planLower = newPlan.toLowerCase();
      final isPremium = planLower == 'vip' || planLower == 'premium';

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'plan': newPlan,
        'premium': isPremium,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("User plan updated."), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = widget.allUsers.where((user) {
      final email = (user.email ?? '').toLowerCase();
      final name = (user.displayName ?? '').toLowerCase();
      return email.contains(_searchQuery) || name.contains(_searchQuery);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: const InputDecoration(
              labelText: "Search by email or name",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
        ),
        if (filteredUsers.isEmpty)
          const Center(child: Text("No users match your search.")).p16(),
        Expanded(
          child: ListView.builder(
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              final user = filteredUsers[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundImage: user.photoURL != null
                        ? NetworkImage(user.photoURL!)
                        : null,
                    child: user.photoURL == null
                        ? Text(user.displayName?[0].toUpperCase() ?? 'U')
                        : null,
                  ),
                  title: Text(user.displayName ?? "No Name"),
                  subtitle: Text(user.email ?? "No Email"),
                  trailing: user.role == 'admin'
                      ? const Icon(Icons.security, color: Colors.red)
                      : (user.hasPaidPlan
                          ? const Icon(Icons.star, color: Colors.amber)
                          : null),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("User Role").pOnly(left: 16),
                              DropdownButton<String>(
                                value: user.role,
                                items: ["user", "vip", "admin"]
                                    .map((role) => DropdownMenuItem(
                                          value: role,
                                          child: Text(role.capitalized),
                                        ))
                                    .toList(),
                                onChanged: (newRole) {
                                  if (newRole != null && newRole != user.role) {
                                    _updateUserRole(user.uid, newRole);
                                  }
                                },
                              ),
                            ],
                          ).pOnly(right: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("User Plan").pOnly(left: 16),
                              DropdownButton<String>(
                                value: user.plan,
                                items: ["Free", "VIP", "Premium"]
                                    .map((plan) => DropdownMenuItem(
                                          value: plan,
                                          child: Text(plan),
                                        ))
                                    .toList(),
                                onChanged: (newPlan) {
                                  if (newPlan != null && newPlan != user.plan) {
                                    _updatePlan(user.uid, newPlan);
                                  }
                                },
                              ),
                            ],
                          ).pOnly(right: 16),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// --- Helper Widget for Dashboard ---
class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 36, color: color),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                value.text.xl4.bold.make(),
                title.text.gray500.make(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
