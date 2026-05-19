class BudgetModel {
  const BudgetModel({
    required this.label,
    required this.limit,
    required this.spent,
  });

  final String label;
  final double limit;
  final double spent;

  double get progress => limit == 0 ? 0 : (spent / limit).clamp(0, 1);
  double get remaining => (limit - spent).clamp(0, double.infinity);
}
