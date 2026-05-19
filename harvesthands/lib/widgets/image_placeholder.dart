import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class ImagePlaceholder extends StatelessWidget {
  final double? height;
  final double iconSize;

  const ImagePlaceholder({
    super.key,
    this.height,
    this.iconSize = 48,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      height: height,
      width: double.infinity,
      color: primary.withValues(alpha: 0.10),
      child: Icon(
        Symbols.image,
        size: iconSize,
        color: primary.withValues(alpha: 0.85),
      ),
    );
  }
}
