import 'package:catalog_app/core/store.dart';
import 'package:catalog_app/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class VipUpsellPage extends StatefulWidget {
  const VipUpsellPage({super.key});

  @override
  State<VipUpsellPage> createState() => _VipUpsellPageState();
}

class _VipUpsellPageState extends State<VipUpsellPage> {
  bool _isProcessing = false;

  Future<void> _updatePlan(String plan) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar(
        'You need to be signed in to change your plan.',
        isError: true,
      );
      return;
    }
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final planTitle = _titleCase(plan);
      final planLower = plan.toLowerCase();

      // Update role based on plan
      String newRole = 'user';
      if (planLower == 'vip') {
        newRole = 'vip';
      } else if (planLower == 'premium') {
        newRole = 'user'; // Premium users keep 'user' role
      } else if (planLower == 'free') {
        newRole = 'user'; // Free users also have 'user' role
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'plan': planTitle,
        'role': newRole,
        'premium': planLower != 'free',
      }, SetOptions(merge: true));

      final refreshedDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (refreshedDoc.exists) {
        LoadUserDataMutation(UserModel.fromFirestore(refreshedDoc));
      }

      final actionWord = planLower == 'free' ? 'downgraded to' : 'changed to';
      _showSnackBar('Successfully $actionWord $planTitle plan!');
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      _showSnackBar('Failed to change plan: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  String _titleCase(String value) {
    if (value.isEmpty) return value;
    final lower = value.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = VxState.store as MyStore;
    final currentPlan = store.plan.toLowerCase();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Plan"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      backgroundColor: context.canvasColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple.shade400, Colors.deepPurple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(28),
                child: Column(
                  children: [
                    Icon(Icons.workspace_premium,
                        color: Colors.white.withValues(alpha: 0.9), size: 60),
                    const SizedBox(height: 16),
                    Text(
                      'Choose Your Experience',
                      style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select or change your plan anytime. You can upgrade or downgrade as needed.',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Available Plans',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              // Free Plan
              _PlanOptionCard(
                title: 'Free Plan',
                price: '\$0.00 / month',
                description: 'Basic access to limited catalog items.',
                perks: const [
                  'View up to 5 catalog items',
                  'Basic search functionality',
                  'Standard support',
                ],
                icon: Icons.card_membership,
                accentColor: Colors.grey,
                onTap: _isProcessing || currentPlan == 'free'
                    ? null
                    : () => _updatePlan('Free'),
                isProcessing: _isProcessing,
                isCurrent: currentPlan == 'free',
              ),
              const SizedBox(height: 20),
              // VIP Plan
              _PlanOptionCard(
                title: 'VIP Plan',
                price: '\$9.99 / month',
                description:
                    'View up to 10 featured catalog items plus VIP-only offers.',
                perks: const [
                  'Extended catalog access (10 items)',
                  'Early access to new collections',
                  'Exclusive discounts and bundles',
                ],
                icon: Icons.star_rounded,
                accentColor: Colors.amber,
                onTap: _isProcessing || currentPlan == 'vip'
                    ? null
                    : () => _updatePlan('VIP'),
                isProcessing: _isProcessing,
                isCurrent: currentPlan == 'vip',
              ),
              const SizedBox(height: 20),
              // Premium Plan
              _PlanOptionCard(
                title: 'Premium Plan',
                price: '\$14.99 / month',
                description: 'Unlock the full catalog with unlimited browsing.',
                perks: const [
                  'Unlimited catalog items',
                  'Priority customer support',
                  'Highest quality images & details',
                ],
                icon: Icons.workspace_premium_outlined,
                accentColor: Colors.deepPurple,
                onTap: _isProcessing || currentPlan == 'premium'
                    ? null
                    : () => _updatePlan('Premium'),
                isProcessing: _isProcessing,
                isCurrent: currentPlan == 'premium',
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _isProcessing
                    ? null
                    : () {
                        Navigator.of(context).pop();
                      },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanOptionCard extends StatelessWidget {
  const _PlanOptionCard({
    required this.title,
    required this.price,
    required this.description,
    required this.perks,
    required this.icon,
    required this.accentColor,
    required this.onTap,
    required this.isProcessing,
    this.isCurrent = false,
  });

  final String title;
  final String price;
  final String description;
  final List<String> perks;
  final IconData icon;
  final Color accentColor;
  final VoidCallback? onTap;
  final bool isProcessing;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      elevation: isCurrent ? 8 : 4,
      borderRadius: BorderRadius.circular(20),
      color: theme.cardColor,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: isCurrent ? Border.all(color: accentColor, width: 3) : null,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: accentColor.withValues(alpha: 0.15),
                      child: Icon(icon, color: accentColor, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  title,
                                  style: theme.textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                              if (isCurrent) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: accentColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'CURRENT',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            price,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: theme.hintColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ...perks.map(
                  (perk) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle,
                            size: 18,
                            color: accentColor.withValues(alpha: 0.8)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            perk,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onTap,
                    style: FilledButton.styleFrom(
                      backgroundColor: isCurrent ? Colors.grey : accentColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: isProcessing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(isCurrent ? 'Current Plan' : 'Choose $title'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
