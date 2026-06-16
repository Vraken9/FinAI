import 'package:flutter/material.dart';

class CategoryIcon extends StatelessWidget {
  final String iconName;
  final String colorHex;
  final double size;

  const CategoryIcon({
    super.key,
    required this.iconName,
    required this.colorHex,
    this.size = 40,
  });

  IconData _getIcon() {
    switch (iconName) {
      case 'food': return Icons.restaurant;
      case 'transport': return Icons.directions_car;
      case 'shopping': return Icons.shopping_bag;
      case 'bills': return Icons.receipt;
      case 'salary': return Icons.attach_money;
      default: return Icons.local_offer;
    }
  }

  Color _getColor() {
    try {
      final hexCode = colorHex.replaceAll('#', '');
      return Color(int.parse('FF$hexCode', radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _getIcon(),
        color: color,
        size: size * 0.5,
      ),
    );
  }
}
