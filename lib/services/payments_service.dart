import '../models/currency.dart';

class PaymentQuote {
  final double amount;
  final String currency;
  final double fee;
  const PaymentQuote(
      {required this.amount, required this.currency, required this.fee});
}

class PaymentsService {
  PaymentQuote quote({required double amount, required String currency}) {
    _requireUsd(currency);
    return PaymentQuote(
        amount: amount, currency: appCurrencyCode, fee: amount * 0.01);
  }

  Future<String> createPayout({
    required double amount,
    required String currency,
    required String recipient,
  }) async {
    _requireUsd(currency);
    return 'mock-payout-${DateTime.now().millisecondsSinceEpoch}';
  }

  void _requireUsd(String currency) {
    if (currency.toUpperCase() != appCurrencyCode) {
      throw ArgumentError.value(
        currency,
        'currency',
        'GlobalPay supports USD only; convert and verify the amount before requesting a payout.',
      );
    }
  }
}
