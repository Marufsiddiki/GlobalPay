import 'worker.dart';

class PayrollRun {
  final String dateRange;
  final List<Worker> workers;
  final double grossPay;
  final double taxes;
  final double benefits;
  final double fees;
  final String status;

  const PayrollRun({
    required this.dateRange,
    required this.workers,
    required this.grossPay,
    required this.taxes,
    required this.benefits,
    required this.fees,
    required this.status,
  });

  double get total => grossPay + taxes + benefits + fees;

  Map<String, dynamic> toMap() => {
        'dateRange': dateRange,
        'workerCount': workers.length,
        'grossPay': grossPay,
        'taxes': taxes,
        'benefits': benefits,
        'fees': fees,
        'status': status,
      };
}