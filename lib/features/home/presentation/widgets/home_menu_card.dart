import 'package:flutter/material.dart';

class HomeMenuCard extends StatelessWidget {
  const HomeMenuCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.aspectRatio,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final double? aspectRatio;

  bool get _isWide => aspectRatio == null;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final borderRadius = BorderRadius.circular(20);

    final iconBadge = Container(
      padding: EdgeInsets.all(_isWide ? 10 : 14),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: _isWide ? 26 : 30, color: colorScheme.primary),
    );

    final titleText = Text(
      title,
      style:
          textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    final subtitleText = Text(
      subtitle,
      style: textTheme.bodySmall
          ?.copyWith(color: colorScheme.onSurfaceVariant),
      textAlign: _isWide ? TextAlign.start : TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );

    final content = _isWide
        ? Row(
            children: [
              iconBadge,
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleText,
                    const SizedBox(height: 4),
                    subtitleText,
                  ],
                ),
              ),
            ],
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              iconBadge,
              const SizedBox(height: 12),
              titleText,
              const SizedBox(height: 4),
              subtitleText,
            ],
          );

    final card = Material(
      color: colorScheme.surfaceContainerLow,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: content,
        ),
      ),
    );

    if (!_isWide) {
      return AspectRatio(aspectRatio: aspectRatio!, child: card);
    }
    return card;
  }
}
