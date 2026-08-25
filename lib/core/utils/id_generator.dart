abstract final class IdGenerator {
  static int _sequence = 0;

  static String nextId() {
    _sequence += 1;
    final timestamp =
        DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    return '$timestamp-$_sequence';
  }
}
