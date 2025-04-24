// lib/models/income_record.dart
class IncomeRecord {
  final String cropName;
  final String section;
  final double amount;
  final DateTime date;
  final String? description;

  IncomeRecord({
    required this.cropName,
    required this.section,
    required this.amount,
    required this.date,
    this.description,
  });
}