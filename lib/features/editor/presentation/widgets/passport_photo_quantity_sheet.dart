import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<int?> showPassportPhotoQuantitySheet(
  BuildContext context, {
  required int current,
}) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _PassportPhotoQuantitySheet(current: current),
  );
}

class _PassportPhotoQuantitySheet extends StatefulWidget {
  const _PassportPhotoQuantitySheet({required this.current});

  final int current;

  @override
  State<_PassportPhotoQuantitySheet> createState() =>
      _PassportPhotoQuantitySheetState();
}

class _PassportPhotoQuantitySheetState
    extends State<_PassportPhotoQuantitySheet> {
  late int _quantity;
  late TextEditingController _controller;

  static const List<int> _quickPresets = [1, 2, 4, 6, 8, 12, 16, 20, 24, 30];

  @override
  void initState() {
    super.initState();
    _quantity = widget.current.clamp(1, 200);
    _controller = TextEditingController(text: _quantity.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setQuantity(int val) {
    final clamped = val.clamp(1, 200);
    setState(() {
      _quantity = clamped;
      _controller.text = clamped.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Jumlah Pas Foto',
                style: textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'Tentukan jumlah foto yang akan disusun pada kertas cetak.',
                style: textTheme.bodySmall
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filledTonal(
                    onPressed: _quantity > 1 ? () => _setQuantity(_quantity - 1) : null,
                    icon: const Icon(Icons.remove),
                    iconSize: 24,
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: _controller,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      ),
                      onChanged: (val) {
                        final parsed = int.tryParse(val);
                        if (parsed != null && parsed > 0) {
                          setState(() => _quantity = parsed.clamp(1, 200));
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton.filledTonal(
                    onPressed: _quantity < 200 ? () => _setQuantity(_quantity + 1) : null,
                    icon: const Icon(Icons.add),
                    iconSize: 24,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  for (final preset in _quickPresets)
                    ActionChip(
                      label: Text('$preset Foto'),
                      backgroundColor: _quantity == preset
                          ? colorScheme.primaryContainer
                          : null,
                      onPressed: () => _setQuantity(preset),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(_quantity),
                child: const Text('Terapkan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

