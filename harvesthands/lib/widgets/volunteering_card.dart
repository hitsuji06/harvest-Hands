import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../models/volunteering.dart';
import '../theme/app_theme.dart';
import 'image_placeholder.dart';

class VolunteeringCard extends StatelessWidget {
  final Volunteering volunteering;
  final VoidCallback? onTap;
  final bool showStatus;

  const VolunteeringCard({
    super.key,
    required this.volunteering,
    this.onTap,
    this.showStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final appColors = Theme.of(context).extension<AppColors>();
    final isClosed = volunteering.isFull || volunteering.isPast;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          volunteering.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (showStatus && isClosed)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: colorScheme.error.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Cerrado',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: colorScheme.error,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                    ],
                  ),
                  if (volunteering.companyName != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Symbols.business,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          volunteering.companyName!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Symbols.event,
                        size: 16,
                        color: appColors?.accentAmber ?? colorScheme.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(volunteering.eventDate),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: appColors?.accentAmber ?? colorScheme.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const Spacer(),
                      Icon(
                        Symbols.group,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${volunteering.enrolledCount}/${volunteering.maxCapacity}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
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
    );
  }

  Widget _buildImage() {
    if (volunteering.imagePath == null) {
      return const ImagePlaceholder(height: 160);
    }

    if (kIsWeb) {
      return Image.network(
        volunteering.imagePath!,
        height: 160,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const ImagePlaceholder(height: 160),
      );
    }

    return Image.file(
      File(volunteering.imagePath!),
      height: 160,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const ImagePlaceholder(height: 160),
    );
  }

  String _formatDate(String isoDate) {
    final dt = DateTime.tryParse(isoDate);
    if (dt == null) return isoDate;
    const meses = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return '${dt.day} ${meses[dt.month - 1]} ${dt.year}';
  }
}
