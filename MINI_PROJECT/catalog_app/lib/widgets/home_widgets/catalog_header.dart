import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class CatalogHeader extends StatelessWidget {
  const CatalogHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 44,
              height: 44,
              child: Image.asset(
                'assets/images/hey.png',
              ),
            ),
            const SizedBox(width: 12),
            "Catalog App"
                .text
                .xl5
                .bold
                .color(context.theme.colorScheme.secondary)
                .make(),
          ],
        ),
        "Trending products".text.xl2.make(),
      ],
    );
  }
}
