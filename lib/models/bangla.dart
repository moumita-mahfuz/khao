const _digits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];

/// 110 → "১১০". Keep raw ints in data; convert only for display.
String toBanglaDigits(int n) => n.toString().split('').map((c) {
  final d = int.tryParse(c);
  return d == null ? c : _digits[d];
}).join();

/// 110 → "৳১১০".
String taka(int n, {String currency = '৳'}) => '$currency${toBanglaDigits(n)}';

/// "01817988622" → "০১৮১৭৯৮৮৬২২". Non-digits are kept as they are.
String banglaDigits(String s) =>
    s.replaceAllMapped(RegExp('[0-9]'), (m) => _digits[int.parse(m[0]!)]);
