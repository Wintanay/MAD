import '../models/expense.dart';

class ExpenseService {
  final List<Expense> _expenses = [];

  // Add a new transaction
  void addExpense(Expense expense) {
    _expenses.add(expense);
  }

  // Get all transactions
  List<Expense> getAllExpenses() {
    return List.unmodifiable(_expenses);
  }

  // Get only expenses
  List<Expense> getExpenses() {
    return _expenses
        .where((e) => e.type == TransactionType.expense)
        .toList();
  }

  // Get only income
  List<Expense> getIncome() {
    return _expenses
        .where((e) => e.type == TransactionType.income)
        .toList();
  }

  // Total balance
  double getTotalBalance() {
    double income = _expenses
        .where((e) => e.type == TransactionType.income)
        .fold(0, (sum, e) => sum + e.amount);
    double expense = _expenses
        .where((e) => e.type == TransactionType.expense)
        .fold(0, (sum, e) => sum + e.amount);
    return income - expense;
  }

  // Delete a transaction
  void deleteExpense(String id) {
    _expenses.removeWhere((e) => e.id == id);
  }
}