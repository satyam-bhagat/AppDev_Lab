// lib/upgrade_to_pro_screen.dart

import 'package:flutter/material.dart';

// --- Models ---
enum PlanType { free, pro, vip }

class CatalogPricingPlan {
  final PlanType type;
  final String title;
  final String subtitle; // e.g., "Most Popular"
  final String monthlyPrice;
  final String yearlyPriceEquivalent; // e.g., "$X/mo*"
  final List<PlanFeature> features; // List of features
  final bool isHighlighted;
  final Color cardColor;
  final Color buttonColor;
  final Color textColor;

  CatalogPricingPlan({
    required this.type,
    required this.title,
    this.subtitle = '',
    required this.monthlyPrice,
    required this.yearlyPriceEquivalent,
    required this.features,
    this.isHighlighted = false,
    this.cardColor = Colors.white,
    this.buttonColor = Colors.blue,
    this.textColor = Colors.black87,
  });
}

class PlanFeature {
  final String text;
  final IconData icon;
  final bool
      isIncluded; // To indicate if a feature is included or not (e.g., for Free plan)

  PlanFeature({required this.text, required this.icon, this.isIncluded = true});
}

// --- Data ---
List<CatalogPricingPlan> getCatalogPricingPlans() {
  return [
    CatalogPricingPlan(
      type: PlanType.free,
      title: 'Free',
      monthlyPrice: '\$0.00 / Month',
      yearlyPriceEquivalent: '\$0.00/mo*', // Can be 'Always Free'
      features: [
        PlanFeature(
            text: 'Limited Product Listings',
            icon: Icons.shopping_bag_outlined),
        PlanFeature(text: 'Basic Search & Filters', icon: Icons.search),
        PlanFeature(text: 'Standard Image Quality', icon: Icons.image_outlined),
        PlanFeature(
            text: 'No Wishlist Sync',
            icon: Icons.favorite_border,
            isIncluded: false),
        PlanFeature(text: 'Standard Support', icon: Icons.support_agent),
      ],
      cardColor: Colors.grey[100]!,
      buttonColor: Colors.grey[400]!,
      textColor: Colors.black54,
    ),
    CatalogPricingPlan(
      type: PlanType.pro,
      title: 'Pro',
      monthlyPrice: '\$4.99 / Month',
      yearlyPriceEquivalent: '\$3.99/mo*',
      features: [
        PlanFeature(
            text: 'Unlimited Product Listings', icon: Icons.shopping_bag),
        PlanFeature(
            text: 'Advanced Search & Filters', icon: Icons.search_outlined),
        PlanFeature(text: 'High-Resolution Images', icon: Icons.high_quality),
        PlanFeature(text: 'Cloud Wishlist Sync', icon: Icons.favorite),
        PlanFeature(text: 'Priority Email Support', icon: Icons.email),
        PlanFeature(text: 'Basic Analytics', icon: Icons.analytics_outlined),
      ],
      cardColor: Colors.white,
      buttonColor: Colors.blue[700]!,
      textColor: Colors.black87,
    ),
    CatalogPricingPlan(
      type: PlanType.vip,
      title: 'VIP',
      subtitle: 'MOST POPULAR',
      monthlyPrice: '\$9.99 / Month',
      yearlyPriceEquivalent: '\$7.99/mo*',
      features: [
        PlanFeature(
            text: 'All Pro Features', icon: Icons.star), // Can combine features
        PlanFeature(
            text: 'Exclusive Early Access', icon: Icons.hourglass_empty),
        PlanFeature(
            text: 'Personal Shopper Service', icon: Icons.person_outline),
        PlanFeature(text: 'Offline Catalog Access', icon: Icons.cloud_off),
        PlanFeature(text: '24/7 Premium Live Chat', icon: Icons.chat),
        PlanFeature(text: 'Custom Branding', icon: Icons.branding_watermark),
      ],
      isHighlighted: true,
      cardColor: Colors.deepPurple[700]!, // Distinct background for VIP
      buttonColor: Colors.orange[700]!,
      textColor: Colors.white,
    ),
  ];
}

// --- Widgets ---

class CatalogPricingPlanCard extends StatelessWidget {
  final CatalogPricingPlan plan;

  const CatalogPricingPlanCard({Key? key, required this.plan})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero, // Remove default card margin
      color: plan.cardColor,
      elevation: plan.isHighlighted ? 10 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(plan.isHighlighted ? 18 : 12),
        side: plan.isHighlighted
            ? BorderSide(color: plan.buttonColor.withAlpha(204), width: 3)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (plan.subtitle.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: plan.textColor.withAlpha(38),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  plan.subtitle.toUpperCase(),
                  style: TextStyle(
                    color: plan.textColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            SizedBox(height: 12),
            Text(
              plan.title,
              style: TextStyle(
                color: plan.textColor,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              plan.monthlyPrice,
              style: TextStyle(
                color: plan.textColor.withAlpha(153),
                fontSize: 15,
                decoration:
                    TextDecoration.lineThrough, // Strikethrough for monthly
              ),
            ),
            Text(
              plan.yearlyPriceEquivalent,
              style: TextStyle(
                color: plan.textColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24),
            ...plan.features.map((feature) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    children: [
                      Icon(
                        feature.icon,
                        color: feature.isIncluded
                            ? plan.textColor.withAlpha(204)
                            : plan.textColor.withAlpha(102),
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          feature.text,
                          style: TextStyle(
                            color: feature.isIncluded
                                ? plan.textColor
                                : plan.textColor.withAlpha(128),
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            Spacer(), // Pushes the button to the bottom
            SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: plan.type == PlanType.free
                    ? null
                    : () {
                        // Handle plan selection logic here
                        print('Selected ${plan.title} Plan for Catalog');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('You chose the ${plan.title} plan!')),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: plan.buttonColor,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: plan.isHighlighted ? 5 : 2,
                ),
                child: Text(
                  plan.type == PlanType.free ? 'Current Plan' : 'Choose Plan',
                  style: TextStyle(
                    color: plan.textColor == Colors.white
                        ? Colors.white
                        : Colors.white, // Ensure text is visible
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (plan.yearlyPriceEquivalent.contains('*'))
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Center(
                  child: Text(
                    '*when billed yearly',
                    style: TextStyle(
                      color: plan.textColor.withAlpha(153),
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class UpgradeToProScreen extends StatelessWidget {
  const UpgradeToProScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final plans = getCatalogPricingPlans();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Upgrade Your Catalog Experience',
          style: TextStyle(color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.grey[200], // Light grey background for the screen

      // --- BODY MODIFIED FOR RESPONSIVENESS ---
      body: SingleChildScrollView(
        // Page scrolls vertically
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Wrap(
          // Wrap arranges children in a row, and "wraps" to the next line
          // if they don't fit.
          alignment: WrapAlignment.center, // Center the cards on the screen
          spacing: 24.0, // Horizontal space between cards
          runSpacing: 24.0, // Vertical space between cards (when they wrap)
          children: plans
              .map((plan) => SizedBox(
                    // Give each card a fixed width
                    width: 360,
                    child: IntrinsicHeight(
                      // This ensures cards in the same row
                      // become the same height, making the 'Spacer' work.
                      child: CatalogPricingPlanCard(plan: plan),
                    ),
                  ))
              .toList(),
        ),
      ),
      // --- END OF MODIFICATION ---
    );
  }
}
