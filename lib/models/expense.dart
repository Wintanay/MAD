enum ExpenseCategory {
  food,
  transport,
  houseRent,
  shopping,
}

enum TransactionType {
  income,
  expense,
}

class Expense {
  final String id;
  final double amount;
  final ExpenseCategory category;
  final TransactionType type;
  final DateTime date;

  Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.type,
    required this.date,
  });
}