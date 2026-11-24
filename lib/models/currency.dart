const appCurrencyCode = 'USD';

String formatUsd(double amount) {
  final formatted = amount.toStringAsFixed(2).replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+\.)'),
        (match) => '${match[1]},',
      );
  return '\$$formatted';
}

String legacyCurrencyForCountry(String country) =>
    const {
      'Singapore': 'SGD',
      'Germany': 'EUR',
      'India': 'INR',
      'United States': 'USD',
      'Bangladesh': 'BDT',
    }[country] ??
    'UNVERIFIED';
