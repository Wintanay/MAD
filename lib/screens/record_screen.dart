import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecordsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> transactions;
  final Function(String) onDelete;
  final Function(String, Map<String, dynamic>) onEdit;

  const RecordsScreen({
    super.key,
    required this.transactions,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  String selectedPeriod = "Week";
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  List<Map<String, dynamic>> get filteredTransactions {
    final now = DateTime.now();
    return widget.transactions.where((t) {
      final date = t['date'] as DateTime;
      bool matchesPeriod;
      if (selectedPeriod == "Week") {
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
        matchesPeriod = date.isAfter(start) || date.isAtSameMomentAs(start);
      } else if (selectedPeriod == "Month") {
        matchesPeriod = date.year == now.year && date.month == now.month;
      } else {
        matchesPeriod = date.year == now.year;
      }

      final matchesSearch = _searchQuery.isEmpty ||
          (t['category'] as String)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());

      return matchesPeriod && matchesSearch;
    }).toList();
  }

  Future<void> _deleteTransaction(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('transactions')
        .doc(id)
        .delete();

    widget.onDelete(id);
  }

  void _confirmDelete(BuildContext context, String id, String category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete Transaction",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          "Are you sure you want to delete \"$category\"?",
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel",
                style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteTransaction(id);
            },
            child: const Text("Delete",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _openEditScreen(BuildContext context, Map<String, dynamic> transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTransactionScreen(
          transaction: transaction,
          onSave: (updatedData) {
            widget.onEdit(transaction['id'], updatedData);
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filteredTransactions;

    double totalIncome = filtered
        .where((t) => t['type'] == 'Income')
        .fold(0.0, (sum, t) => sum + (t['amount'] as double));

    double totalExpense = filtered
        .where((t) => t['type'] == 'Expense')
        .fold(0.0, (sum, t) => sum + (t['amount'] as double));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Records",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: "Search by category...",
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() => _searchQuery = "");
                          },
                          child: const Icon(Icons.close, color: Colors.grey, size: 18),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ),
          ),
          // Period tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _timeTab("Week", selectedPeriod == "Week"),
                  _timeTab("Month", selectedPeriod == "Month"),
                  _timeTab("Year", selectedPeriod == "Year"),
                ],
              ),
            ),
          ),
          // Income / Expense totals
          if (filtered.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Text("Income",
                              style: TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text("+${totalIncome.toStringAsFixed(2)} ETB",
                              style: const TextStyle(
                                  color: Color(0xFF00C853),
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Text("Expense",
                              style: TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text("-${totalExpense.toStringAsFixed(2)} ETB",
                              style: const TextStyle(
                                  color: Color(0xFFEF5350),
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 6),
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      bool isExpense = item['type'] == 'Expense';
                      return _buildTransactionTile(context, item, isExpense);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _timeTab(String label, bool isActive) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedPeriod = label),
        child: Container(
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          _searchQuery.isNotEmpty
              ? Icons.search_off
              : Icons.description_outlined,
          size: 100,
          color: Colors.grey[300],
        ),
        const SizedBox(height: 20),
        Text(
          _searchQuery.isNotEmpty
              ? "No results for \"$_searchQuery\""
              : "No records yet",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          _searchQuery.isNotEmpty
              ? "Try a different category name"
              : "Your expenses will appear here",
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildTransactionTile(
      BuildContext context, Map<String, dynamic> item, bool isExpense) {
    final date = item['date'] as DateTime;
    final formattedDate = "${date.day}/${date.month}/${date.year}";

    return Dismissible(
      key: Key(item['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.red),
      ),
      confirmDismiss: (_) async {
        bool confirm = false;
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: const Text("Delete Transaction",
                style: TextStyle(fontWeight: FontWeight.bold)),
            content: Text(
              "Are you sure you want to delete \"${item['category']}\"?",
              style: const TextStyle(color: Colors.grey),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  confirm = false;
                  Navigator.pop(ctx);
                },
                child: const Text("Cancel",
                    style: TextStyle(color: Colors.black)),
              ),
              TextButton(
                onPressed: () {
                  confirm = true;
                  Navigator.pop(ctx);
                },
                child: const Text("Delete",
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
        return confirm;
      },
      onDismissed: (_) => _deleteTransaction(item['id']),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          onTap: () => _openEditScreen(context, item),
          leading: CircleAvatar(
            backgroundColor:
                isExpense ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
            child: Icon(
              isExpense
                  ? Icons.keyboard_double_arrow_down
                  : Icons.keyboard_double_arrow_up,
              color: isExpense
                  ? const Color(0xFFEF5350)
                  : const Color(0xFF00C853),
            ),
          ),
          title: Text(item['category'],
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(formattedDate,
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${isExpense ? '-' : '+'}${item['amount'].toStringAsFixed(2)} ETB",
                style: TextStyle(
                    color: isExpense
                        ? const Color(0xFFEF5350)
                        : const Color(0xFF00C853),
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () =>
                    _confirmDelete(context, item['id'], item['category']),
                child: const Icon(Icons.delete_outline,
                    color: Colors.grey, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Edit Screen ───────────────────────────────────────────────────────────────

class EditTransactionScreen extends StatefulWidget {
  final Map<String, dynamic> transaction;
  final Function(Map<String, dynamic>) onSave;

  const EditTransactionScreen({
    super.key,
    required this.transaction,
    required this.onSave,
  });

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  late String transactionType;
  late String selectedCategory;
  late TextEditingController _amountController;
  bool _isSaving = false;

  final List<String> expenseCategories = [
    "Food", "Transport", "House Rent", "Shopping",
    "Medical", "Education", "Entertainment", "Utilities"
  ];
  final List<String> incomeCategories = [
    "Salary", "Gift", "Interest", "Freelance", "Investment", "Rental"
  ];

  @override
  void initState() {
    super.initState();
    transactionType = widget.transaction['type'];
    selectedCategory = widget.transaction['category'];
    _amountController = TextEditingController(
        text: widget.transaction['amount'].toString());
    _loadCustomCategories();
  }

  Future<void> _loadCustomCategories() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('categories')
        .doc('custom')
        .get();

    if (doc.exists) {
      final data = doc.data();
      if (data != null) {
        final List expCats = data['expense'] ?? [];
        final List incCats = data['income'] ?? [];
        setState(() {
          for (final cat in expCats) {
            if (!expenseCategories.contains(cat)) expenseCategories.add(cat);
          }
          for (final cat in incCats) {
            if (!incomeCategories.contains(cat)) incomeCategories.add(cat);
          }
          // make sure current category is in the list
          if (transactionType == 'Expense' &&
              !expenseCategories.contains(selectedCategory)) {
            expenseCategories.add(selectedCategory);
          }
          if (transactionType == 'Income' &&
              !incomeCategories.contains(selectedCategory)) {
            incomeCategories.add(selectedCategory);
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  List<String> get currentCategories =>
      transactionType == 'Expense' ? expenseCategories : incomeCategories;

  Future<void> _saveEdit() async {
    final double? amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Enter a valid amount")));
      return;
    }

    if (!currentCategories.contains(selectedCategory)) {
      selectedCategory = currentCategories.first;
    }

    setState(() => _isSaving = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final updatedData = {
      'category': selectedCategory,
      'amount': amount,
      'type': transactionType,
      'date': widget.transaction['date'],
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('transactions')
        .doc(widget.transaction['id'])
        .update({
      'category': selectedCategory,
      'amount': amount,
      'type': transactionType,
    });

    widget.onSave(updatedData);
    setState(() => _isSaving = false);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Edit Transaction",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      transactionType = "Expense";
                      selectedCategory = expenseCategories.first;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 10),
                    decoration: BoxDecoration(
                      color: transactionType == "Expense"
                          ? Colors.red[100]
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Expense",
                      style: TextStyle(
                        color: transactionType == "Expense"
                            ? Colors.red[900]
                            : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      transactionType = "Income";
                      selectedCategory = incomeCategories.first;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 10),
                    decoration: BoxDecoration(
                      color: transactionType == "Income"
                          ? Colors.green[100]
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Income",
                      style: TextStyle(
                        color: transactionType == "Income"
                            ? Colors.green[900]
                            : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF2D2E33),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Text("Edit $transactionType",
                      style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      hintText: "0.00",
                      hintStyle: TextStyle(color: Colors.white38),
                      suffixText: " ETB",
                      suffixStyle:
                          TextStyle(color: Colors.white70, fontSize: 16),
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text("Choose category",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...currentCategories.map((cat) {
              bool isSelected = selectedCategory == cat;
              return GestureDetector(
                onTap: () => setState(() => selectedCategory = cat),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFE8F5E9)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                    border: isSelected
                        ? Border.all(color: const Color(0xFF00C853))
                        : null,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: isSelected
                            ? const Color(0xFF00C853)
                            : Colors.grey[200],
                        child: Icon(
                          _categoryIcon(cat),
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Text(cat,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      if (isSelected)
                        const Icon(Icons.check_circle,
                            color: Color(0xFF00C853)),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveEdit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save Changes",
                        style:
                            TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case "Food":
        return Icons.restaurant;
      case "Transport":
        return Icons.directions_bus;
      case "House Rent":
        return Icons.home;
      case "Shopping":
        return Icons.shopping_basket;
      case "Medical":
        return Icons.local_hospital;
      case "Education":
        return Icons.school;
      case "Entertainment":
        return Icons.movie;
      case "Utilities":
        return Icons.bolt;
      case "Salary":
        return Icons.work;
      case "Gift":
        return Icons.card_giftcard;
      case "Interest":
        return Icons.savings;
      case "Freelance":
        return Icons.laptop;
      case "Investment":
        return Icons.trending_up;
      case "Rental":
        return Icons.house;
      default:
        return Icons.label;
    }
  }
}