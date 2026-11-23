import 'dart:math';

String newRecordId() {
  final randomPart = Random.secure().nextInt(1 << 32).toRadixString(16);
  return '${DateTime.now().microsecondsSinceEpoch}-$randomPart';
}
