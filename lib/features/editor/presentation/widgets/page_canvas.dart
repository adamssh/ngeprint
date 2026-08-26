import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/layout_element.dart';
import '../../../../core/constants/paper_sizes.dart';

class PageCanvas extends StatelessWidget {
  const PageCanvas({
    super.key,
    required this.paperSize,
    required this.elements,
  });

  final PaperSize paperSize;
  final List<LayoutElement> elements;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth - 32;
        final availableHeight = constraints.maxHeight - 32;
        if (availableWidth <= 0 || availableHeight <= 0) {
          return const SizedBox.shrink();
        }
        final scale = math.min(
          availableWidth / paperSize.widthMm,
          availableHeight / paperSize.heightMm,
        );
        final canvasWidth = paperSize.widthMm * scale;
        final canvasHeight = paperSize.heightMm * scale;

        return Center(
          child: Container(
            width: canvasWidth,
            height: canvasHeight,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                for (final element in elements)
                  Positioned(
                    left: element.xMm * scale,
                    top: element.yMm * scale,
                    width: element.widthMm * scale,
                    height: element.heightMm * scale,
                    child: _ElementView(element: element),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ElementView extends StatelessWidget {
  const _ElementView({required this.element});

  final LayoutElement element;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final quarterTurns = (element.rotationDeg ~/ 90) % 4;
    return RotatedBox(
      quarterTurns: quarterTurns,
      child: Image.file(
        File(element.sourcePath),
        fit: BoxFit.fill,
        filterQuality: FilterQuality.medium,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => ColoredBox(
          color: colorScheme.surfaceContainerHighest,
          child: Icon(
            Icons.broken_image_outlined,
            size: 40,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
