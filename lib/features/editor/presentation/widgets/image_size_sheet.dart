import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/paper_sizes.dart';
import '../../../../core/utils/length_formatter.dart';
import '../../../../core/utils/unit_converter.dart';
import '../../models/layout_element.dart';

sealed class ImageSizeResult {
  const ImageSizeResult();
}

class FitToPageResult extends ImageSizeResult {
  const FitToPageResult();
}

class ManualSizeResult extends ImageSizeResult {
  const ManualSizeResult({required this.widthMm, required this.heightMm});

  final double widthMm;
  final double heightMm;
}

Future<ImageSizeResult?> showImageSizeSheet(
  BuildContext context, {
  required LayoutElement element,
  required PaperSize paperSize,
}) {
  return showModalBottomSheet<ImageSizeResult>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _ImageSizeSheet(
      element: element,
      paperSize: paperSize,
    ),
  );
}

enum _SizeModeOption { fitToPage, manual }

class _ImageSizeSheet extends StatefulWidget {
  const _ImageSizeSheet({required this.element, required this.paperSize});

  final LayoutElement element;
  final PaperSize paperSize;

  @override
  State<_ImageSizeSheet> createState() => _ImageSizeSheetState();
}

class _ImageSizeSheetState extends State<_ImageSizeSheet> {
  late _SizeModeOption _mode;
  late PhysicalUnit _unit;
  late bool _lockRatio;
  late TextEditingController _widthController;
  late TextEditingController _heightController;

  double? get _aspectRatio {
    final effective = widget.element.effectiveAspectRatio;
    if (effective != null) return effective;
    if (widget.element.heightMm > 0) {
      return widget.element.widthMm / widget.element.heightMm;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _mode = widget.element.sizeMode == ElementSizeMode.manual
        ? _SizeModeOption.manual
        : _SizeModeOption.fitToPage;
    _unit = PhysicalUnit.millimeter;
    _lockRatio = true;
    _widthController = TextEditingController(
      text: LengthFormatter.format(widget.element.widthMm, _unit),
    );
    _heightController = TextEditingController(
      text: LengthFormatter.format(widget.element.heightMm, _unit),
    );
  }

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
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
                'Ukuran Gambar',
                style: textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'Hanya berlaku untuk gambar di halaman ini.',
                style: textTheme.bodySmall
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              _buildModeTile(
                option: _SizeModeOption.fitToPage,
                title: 'Pas ke halaman',
                subtitle: 'Gambar menyesuaikan kertas tanpa terpotong',
              ),
              _buildModeTile(
                option: _SizeModeOption.manual,
                title: 'Ukuran manual',
                subtitle: 'Tentukan panjang dan tinggi sendiri',
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: _mode == _SizeModeOption.manual
                    ? _buildManualForm(context)
                    : const SizedBox.shrink(key: ValueKey('manual-empty')),
              ),
              if (_mode == _SizeModeOption.manual &&
                  _exceedsPageSize()) ...[
                const SizedBox(height: 4),
                Text(
                  'Melebihi ukuran halaman; akan diskalakan agar muat.',
                  style: textTheme.bodySmall
                      ?.copyWith(color: colorScheme.error),
                ),
              ],
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

  Widget _buildModeTile({
    required _SizeModeOption option,
    required String title,
    required String subtitle,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _mode == option;
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Icon(
        isSelected
            ? Icons.radio_button_checked
            : Icons.radio_button_unchecked,
        color:
            isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: () => setState(() => _mode = option),
    );
  }

  Widget _buildManualForm(BuildContext context) {
    return Padding(
      key: const ValueKey('manual-form'),
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _widthController,
                  keyboardType:
                      TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  onChanged: (_) => _onWidthChanged(),
                  decoration: InputDecoration(
                    labelText: _lockRatio ? 'Lebar (terkunci)' : 'Lebar',
                    suffixText: _unit.symbol,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              IconButton(
                onPressed: _toggleLock,
                tooltip: _lockRatio
                    ? 'Rasio terkunci, klik untuk lepas'
                    : 'Kunci rasio lebar–tinggi',
                icon: Icon(
                  _lockRatio ? Icons.lock_rounded : Icons.lock_open_rounded,
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: _heightController,
                  keyboardType:
                      TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  onChanged: (_) => _onHeightChanged(),
                  decoration: InputDecoration(
                    labelText: _lockRatio ? 'Tinggi (terkunci)' : 'Tinggi',
                    suffixText: _unit.symbol,
                    border: const OutlineInputBorder(),
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
        ],
      ),
    );
  }

  bool _exceedsPageSize() {
    final width = LengthFormatter.parse(_widthController.text);
    final height = LengthFormatter.parse(_heightController.text);
    if (width == null || height == null) return false;
    final widthMm = UnitConverter.toMillimeters(width, _unit);
    final heightMm = UnitConverter.toMillimeters(height, _unit);
    return widthMm > widget.paperSize.widthMm ||
        heightMm > widget.paperSize.heightMm;
  }

  void _onWidthChanged() {
    if (!_lockRatio) return;
    final aspect = _aspectRatio;
    if (aspect == null || aspect <= 0) return;
    final width = LengthFormatter.parse(_widthController.text);
    if (width == null) return;
    final heightMm =
        UnitConverter.toMillimeters(width, _unit) / aspect;
    _heightController.text =
        LengthFormatter.format(heightMm, _unit);
  }

  void _onHeightChanged() {
    if (!_lockRatio) return;
    final aspect = _aspectRatio;
    if (aspect == null || aspect <= 0) return;
    final height = LengthFormatter.parse(_heightController.text);
    if (height == null) return;
    final widthMm =
        UnitConverter.toMillimeters(height, _unit) * aspect;
    _widthController.text =
        LengthFormatter.format(widthMm, _unit);
  }

  void _toggleLock() {
    setState(() {
      _lockRatio = !_lockRatio;
      if (_lockRatio) _onWidthChanged();
    });
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
    if (_mode == _SizeModeOption.fitToPage) {
      Navigator.of(context).pop(const FitToPageResult());
      return;
    }
    final width = LengthFormatter.parse(_widthController.text);
    final height = LengthFormatter.parse(_heightController.text);
    if (width == null || height == null) return;
    Navigator.of(context).pop(
      ManualSizeResult(
        widthMm: UnitConverter.toMillimeters(width, _unit),
        heightMm: UnitConverter.toMillimeters(height, _unit),
      ),
    );
  }
}
