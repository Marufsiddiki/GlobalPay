class PaymentQuote {
  final double amount;
  final String currency;
  final double fee;
  const PaymentQuote({required this.amount, required this.currency, required this.fee});
}

class PaymentsService {
  PaymentQuote quote({required double amount, required String currency}) => PaymentQuote(amount: amount, currency: currency, fee: amount * 0.01);
  Future<String> createPayout({required double amount, required String currency, required String recipient}) async => 'mock-payout-${DateTime.now().millisecondsSinceEpoch}';
}