import 'package:flutter/material.dart';

class BulletLegend extends StatelessWidget {
  final Color color;
  final String text;

  const BulletLegend({
    super.key,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 12)),
        ],
      );
}
