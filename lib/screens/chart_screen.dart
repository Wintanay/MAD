import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../main.dart';

class ChartsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> transactions;

  const ChartsScreen({super.key, required this.transactions});

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  String selectedPeriod = "Week";

  List<Map<String, dynamic>> get filteredTransactions {
    final now = DateTime.now();
    return widget.transactions.where((t) {
      final date = t['date'] as DateTime;
      if (selectedPeriod == "Week") {
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
        return date.isAfter(start) || date.isAtSameMomentAs(start);
      } else if (selectedPeriod == "Month") {
        return date.year == now.year && date.month == now.month;
      } else {
        return date.year == now.year;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    final filtered = filteredTransactions;

    double totalIncome = filtered
        .where((t) => t['type'] == 'Income')
        .fold(0.0, (sum, t) => sum + (t['amount'] as double));

    double totalExpense = filtered
        .where((t) => t['type'] == 'Expense')
        .fold(0.0, (sum, t) => sum + (t['amount'] as double));

    double total = totalIncome + totalExpense;
    double expensePercent = total == 0 ? 0 : totalExpense / total;
    double incomePercent = total == 0 ? 0 : totalIncome / total;

    final bgColor = isDark ? const Color(0xFF121212) : Colors.white;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE8F5E9);
    final cardColorRed = isDark ? const Color(0xFF2A1A1A) : const Color(0xFFFFEBEE);
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("Spending Analysis",
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: bgColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
          const SizedBox(height: 30),
          filtered.isEmpty
              ? Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bar_chart_outlined,
                          size: 100, color: Colors.grey[600]),
                      const SizedBox(height: 20),
                      Text(
                        "No data for this period",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor),
                      ),
                      const Text(
                        "Add transactions to see your analysis",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 220,
                          width: 220,
                          child: CustomPaint(
                            painter: DonutChartPainter(
                              incomePercent: incomePercent,
                              expensePercent: expensePercent,
                              isDark: isDark,
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Expense",
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 13),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${(expensePercent * 100).toStringAsFixed(0)}%",
                                    style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: textColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _legendDot(const Color(0xFF00C853), "Income"),
                            const SizedBox(width: 24),
                            _legendDot(const Color(0xFFEF5350), "Expense"),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text("Income",
                                          style: TextStyle(
                                              color: Colors.grey, fontSize: 13)),
                                      const SizedBox(height: 6),
                                      Text(
                                        "+${totalIncome.toStringAsFixed(2)} ETB",
                                        style: const TextStyle(
                                            color: Color(0xFF00C853),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    color: cardColorRed,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text("Expense",
                                          style: TextStyle(
                                              color: Colors.grey, fontSize: 13)),
                                      const SizedBox(height: 6),
                                      Text(
                                        "-${totalExpense.toStringAsFixed(2)} ETB",
                                        style: const TextStyle(
                                            color: Color(0xFFEF5350),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        _buildCategoryBreakdown(filtered, isDark),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ],
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

  Widget _buildCategoryBreakdown(List<Map<String, dynamic>> filtered, bool isDark) {
    final Map<String, double> categoryTotals = {};
    for (final t in filtered) {
      if (t['type'] == 'Expense') {
        final cat = t['category'] as String;
        categoryTotals[cat] =
            (categoryTotals[cat] ?? 0) + (t['amount'] as double);
      }
    }

    if (categoryTotals.isEmpty) return const SizedBox();

    final total = categoryTotals.values.fold(0.0, (a, b) => a + b);
    final textColor = isDark ? Colors.white : Colors.black;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("By Category",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: textColor)),
          const SizedBox(height: 12),
          ...categoryTotals.entries.map((entry) {
            final percent = total == 0 ? 0.0 : entry.value / total;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 90,
                    child: Text(entry.key,
                        style: TextStyle(fontSize: 13, color: textColor)),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: percent,
                        minHeight: 10,
                        backgroundColor: isDark
                            ? Colors.grey[800]
                            : Colors.grey[200],
                        color: const Color(0xFFEF5350),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "${(percent * 100).toStringAsFixed(0)}%",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: textColor),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final double incomePercent;
  final double expensePercent;
  final bool isDark;

  DonutChartPainter({
    required this.incomePercent,
    required this.expensePercent,
    this.isDark = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 38.0;
    final rect = Rect.fromCircle(
        center: center, radius: radius - strokeWidth / 2);

    final backgroundPaint = Paint()
      ..color = isDark ? Colors.grey.shade800 : Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    canvas.drawCircle(center, radius - strokeWidth / 2, backgroundPaint);

    if (incomePercent > 0) {
      final incomePaint = Paint()
        ..color = const Color(0xFF00C853)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * incomePercent,
        false,
        incomePaint,
      );
    }

    if (expensePercent > 0) {
      final expensePaint = Paint()
        ..color = const Color(0xFFEF5350)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        rect,
        -math.pi / 2 + 2 * math.pi * incomePercent,
        2 * math.pi * expensePercent,
        false,
        expensePaint,
      );
    }
  }

  @override
  bool shouldRepaint(DonutChartPainter oldDelegate) =>
      oldDelegate.incomePercent != incomePercent ||
      oldDelegate.expensePercent != expensePercent ||
      oldDelegate.isDark != isDark;
}