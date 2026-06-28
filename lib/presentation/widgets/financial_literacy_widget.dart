import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

/// FinancialLiteracyWidget offers budgeting tools, income/expense logging, and savings logs.
class FinancialLiteracyWidget extends StatefulWidget {
  final double farmSize; // in Hectares

  const FinancialLiteracyWidget({
    super.key,
    required this.farmSize,
  });

  @override
  State<FinancialLiteracyWidget> createState() => _FinancialLiteracyWidgetState();
}

class _FinancialLiteracyWidgetState extends State<FinancialLiteracyWidget> {
  late Box _financialBox;
  bool _isInitialized = false;

  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  String _transactionType = 'Income'; // Income or Expense

  final _savingsGoalController = TextEditingController();
  double _savingsGoal = 100000.0; // Default: 100,000 RWF
  double _currentSavings = 35000.0; // Default: 35,000 RWF

  List<Map<String, dynamic>> _records = [];

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _categoryController.dispose();
    _savingsGoalController.dispose();
    super.dispose();
  }

  Future<void> _openBox() async {
    _financialBox = await Hive.openBox('financial_records');
    
    // Load existing goal & savings
    _savingsGoal = _financialBox.get('savings_goal', defaultValue: 100000.0) as double;
    _currentSavings = _financialBox.get('current_savings', defaultValue: 35000.0) as double;
    _savingsGoalController.text = _savingsGoal.toStringAsFixed(0);

    // Load records
    final rawRecords = _financialBox.get('records', defaultValue: []) as List;
    _records = rawRecords.map((item) => Map<String, dynamic>.from(item as Map)).toList();

    setState(() {
      _isInitialized = true;
    });
  }

  Future<void> _addRecord() async {
    final amount = double.tryParse(_amountController.text.trim());
    final category = _categoryController.text.trim();

    if (amount == null || amount <= 0 || category.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount and category.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newRecord = {
      'amount': amount,
      'category': category,
      'type': _transactionType,
      'date': DateTime.now().toString().substring(0, 16),
    };

    setState(() {
      _records.insert(0, newRecord);
      if (_transactionType == 'Income') {
        _currentSavings += amount * 0.1; // Auto-budget 10% income to savings
      } else {
        _currentSavings -= amount * 0.05; // Subtract 5% of expense from cash savings
        if (_currentSavings < 0) _currentSavings = 0;
      }
    });

    await _financialBox.put('records', _records);
    await _financialBox.put('current_savings', _currentSavings);

    _amountController.clear();
    _categoryController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transaction logged successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _updateSavingsGoal() async {
    final goal = double.tryParse(_savingsGoalController.text.trim());
    if (goal != null && goal > 0) {
      setState(() {
        _savingsGoal = goal;
      });
      await _financialBox.put('savings_goal', goal);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Savings goal updated!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 4.0),
      );
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Quick Budgeting Calculator (Estimations based on farm size in Hectares)
    final size = widget.farmSize > 0 ? widget.farmSize : 1.0;
    final seedCost = size * 25000; // 25,000 RWF per Ha
    final fertilizerCost = size * 60000; // 60,000 RWF per Ha
    final laborCost = size * 30000; // 30,000 RWF per Ha
    final totalProjectedCost = seedCost + fertilizerCost + laborCost;

    // Savings Progress ratio
    final savingsRatio = (_currentSavings / _savingsGoal).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Savings Goal Tracker
        Text(
          'Savings Goal Tracker',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: isDark ? Colors.white54 : Colors.black, width: 2.0),
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Savings Goal (RWF):',
                    style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87),
                  ),
                  SizedBox(
                    width: 120,
                    height: 40,
                    child: TextField(
                      controller: _savingsGoalController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _updateSavingsGoal(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Current Savings:',
                    style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87),
                  ),
                  Text(
                    '${_currentSavings.toStringAsFixed(0)} / ${_savingsGoal.toStringAsFixed(0)} RWF',
                    style: TextStyle(fontWeight: FontWeight.w900, color: theme.colorScheme.primary, fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Stack(
                children: [
                  Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.black12,
                      border: Border.all(color: isDark ? Colors.white30 : Colors.black26),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: savingsRatio,
                    child: Container(
                      height: 16,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        border: Border.all(color: isDark ? Colors.white : Colors.black, width: 1.0),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${(savingsRatio * 100).toStringAsFixed(0)}% of goal achieved',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // 2. Budgeting Cost Calculator
        Text(
          'Seasonal Input Budget Projections',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: isDark ? Colors.white30 : Colors.black26),
            color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[50],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Estimated costs projected for a $size Ha farm:',
                style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13),
              ),
              const Divider(height: 20),
              _buildCostRow('Seed Cost Estimate', seedCost, isDark),
              _buildCostRow('Fertilizer Cost Estimate', fertilizerCost, isDark),
              _buildCostRow('Labor Cost Estimate', laborCost, isDark),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Budget Estimate:', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                  Text(
                    '${totalProjectedCost.toStringAsFixed(0)} RWF',
                    style: TextStyle(fontWeight: FontWeight.w900, color: theme.colorScheme.primary, fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // 3. Income/Expense Logger Form
        Text(
          'Log Income & Expenses',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: isDark ? Colors.white54 : Colors.black, width: 2.0),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Income', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      value: 'Income',
                      groupValue: _transactionType,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        setState(() => _transactionType = val!);
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Expense', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      value: 'Expense',
                      groupValue: _transactionType,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        setState(() => _transactionType = val!);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount (RWF)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category (e.g., Seeds, Maize Sale)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(6.0)),
                    ),
                  ),
                  onPressed: _addRecord,
                  child: const Text('LOG TRANSACTION', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // 4. Recent Transactions List
        if (_records.isNotEmpty) ...[
          Text(
            'Recent Logs',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _records.length > 5 ? 5 : _records.length,
            itemBuilder: (context, index) {
              final item = _records[index];
              final isIncome = item['type'] == 'Income';
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: isDark ? Colors.white24 : Colors.black12),
                ),
                child: ListTile(
                  leading: Icon(
                    isIncome ? Icons.add_circle : Icons.remove_circle,
                    color: isIncome ? Colors.green : Colors.red,
                  ),
                  title: Text(
                    item['category'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(item['date'] as String),
                  trailing: Text(
                    '${isIncome ? "+" : "-"}${item['amount'].toStringAsFixed(0)} RWF',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: isIncome ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
        ],

        // 5. Financial Literacy scroll tips
        Text(
          'Financial Literacy Tips',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: isDark ? Colors.white30 : Colors.black26),
            color: theme.colorScheme.primary.withValues(alpha: 0.05),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '💡 Rule of Thumb: Budget 50% for inputs, 30% for unexpected risks, and save 20% of yield profits.',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              SizedBox(height: 8),
              Text(
                '💡 Group savings: Join a local agricultural cooperative (Ejo Heza) to share seed purchase expenses.',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCostRow(String title, double value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13)),
          Text(
            '${value.toStringAsFixed(0)} RWF',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
