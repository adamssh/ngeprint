import 'layout_element.dart';

class LayoutPage {
  const LayoutPage({required this.index, required this.elements});

  final int index;
  final List<LayoutElement> elements;

  LayoutPage copyWith({
    int? index,
    List<LayoutElement>? elements,
  }) {
    return LayoutPage(
      index: index ?? this.index,
      elements: elements ?? this.elements,
    );
  }
}
