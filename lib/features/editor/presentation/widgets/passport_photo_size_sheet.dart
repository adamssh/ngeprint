import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/photo_size_presets.dart';
import '../../../../core/utils/length_formatter.dart';
import '../../../../core/utils/unit_converter.dart';

Future<PhotoSizePreset?> showPassportPhotoSizeSheet(
  BuildContext context, {
  required PhotoSizePreset current,
}) {
  return showModalBottomSheet<PhotoSizePreset>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _PassportPhotoSizeSheet(current: current),
  );
}

class _PassportPhotoSizeSheet extends StatefulWidget {
  const _PassportPhotoSizeSheet({required this.current});

  final PhotoSizePreset current;

  @override
  State<_PassportPhotoSizeSheet> createState() =>
      _PassportPhotoSizeSheetState();
}

class _PassportPhotoSizeSheetState extends State<_PassportPhotoSizeSheet> {
  late PhotoSizePreset _selected;
  late PhysicalUnit _unit;
  late TextEditingController _widthController;
  late TextEditingController _heightController;

  @override
  void initState() {
    super.initState();
    _selected = widget.current;
    _unit = PhysicalUnit.millimeter;
    final widthText =
        LengthFormatter.format(widget.current.widthMm, _unit);
    final heightText =
        LengthFormatter.format(widget.current.heightMm, _unit);
    _widthController = TextEditingController(text: widthText);
    _heightController = TextEditingController(text: heightText);
  }

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  bool get _isCustomSelected => _selected.id == PhotoSizePreset.custom.id;

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
                'Ukuran Pas Foto',
                style: textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'Pilih preset ukuran pas foto atau tentukan ukuran kustom.',
                style: textTheme.bodySmall
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              ...PhotoSizePreset.selectablePresets.map(_buildTile),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: _isCustomSelected
                    ? _buildCustomForm(context)
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _apply,
                child: const Text('Terapkan'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTile(PhotoSizePreset preset) {
    final isSelected = preset.id == _selected.id;
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Icon(
        isSelected
            ? Icons.radio_button_checked
            : Icons.radio_button_unchecked,
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: Text(preset.label),
      subtitle: Text(preset.dimensionLabel),
      onTap: () => setState(() => _selected = preset),
    );
  }

  Widget _buildCustomForm(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      key: const ValueKey('custom-photo-form'),
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _widthController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Lebar',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child:
                    Text('×', style: Theme.of(context).textTheme.titleMedium),
              ),
              Expanded(
                child: TextFormField(
                  controller: _heightController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Tinggi',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<PhysicalUnit>(
              segments: const [
                ButtonSegment(value: PhysicalUnit.millimeter, label: Text('mm')),
                ButtonSegment(value: PhysicalUnit.centimeter, label: Text('cm')),
                ButtonSegment(value: PhysicalUnit.inch, label: Text('inci')),
              ],
              selected: {_unit},
              onSelectionChanged: (selection) =>
                  _onUnitChanged(selection.first),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ukuran foto akan diterapkan pada kisi cetak.',
            style: textTheme.bodySmall
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  void _onUnitChanged(PhysicalUnit newUnit) {
    final widthValue = LengthFormatter.parse(_widthController.text);
    final heightValue = LengthFormatter.parse(_heightController.text);
    setState(() {
      if (widthValue != null) {
        final widthMm = UnitConverter.toMillimeters(widthValue, _unit);
        _widthController.text = LengthFormatter.format(widthMm, newUnit);
      }
      if (heightValue != null) {
        final heightMm = UnitConverter.toMillimeters(heightValue, _unit);
        _heightController.text = LengthFormatter.format(heightMm, newUnit);
      }
      _unit = newUnit;
    });
  }

  void _apply() {
    if (!_isCustomSelected) {
      Navigator.of(context).pop(_selected);
      return;
    }
    final width = LengthFormatter.parse(_widthController.text);
    final height = LengthFormatter.parse(_heightController.text);
    if (width == null || height == null) return;
    Navigator.of(context).pop(
      PhotoSizePreset.custom.copyWith(
        widthMm: UnitConverter.toMillimeters(width, _unit),
        heightMm: UnitConverter.toMillimeters(height, _unit),
      ),
    );
  }
}

