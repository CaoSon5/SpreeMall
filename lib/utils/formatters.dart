
library;

String formatVnd(num amount) {
  final str = amount.round().toString();
  final reversed = str.split('').reversed.toList();
  final grouped = <String>[];

  for (int i = 0; i < reversed.length; i++) {
    if (i != 0 && i % 3 == 0) {
      grouped.add('.');
    }
    grouped.add(reversed[i]);
  }

  final result = grouped.reversed.join();
  return '${result}đ';
}
