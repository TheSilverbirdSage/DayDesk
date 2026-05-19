class Helpers {
  static String currency(num value) {
    final text = value.toStringAsFixed(2);
    final parts = text.split('.');
    final whole = parts.first.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
    return '\$$whole.${parts.last}';
  }
}
