import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../data/categories.dart';
import '../models/recurring_template.dart';
import '../models/transaction_entry.dart';
import '../state/app_state.dart';
import '../widgets/primary_button.dart';
import 'receipt_scan_screen.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  static const routeName = '/add-expense';

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _date = DateTime.now();
  TransactionType _type = TransactionType.expense;
  String _category = expenseCategories.first;
  bool _recurring = false;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final appState = context.read<AppState>();
    final recurringId = _recurring ? const Uuid().v4() : null;
    if (_recurring) {
      final currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
      await appState.addRecurringTemplate(
        RecurringTemplate(
          id: recurringId!,
          title: _titleController.text,
          amount: double.parse(_amountController.text),
          category: _category,
          type: _type,
          dayOfMonth: _date.day,
          lastAppliedMonth: currentMonth,
        ),
      );
    }
    await appState.addTransaction(
      title: _titleController.text,
      amount: double.parse(_amountController.text),
      category: _category,
      type: _type,
      date: _date,
      recurringId: recurringId,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categories = _type == TransactionType.expense ? expenseCategories : incomeCategories;

    return Scaffold(
      appBar: AppBar(title: const Text('Add entry')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                SegmentedButton<TransactionType>(
                  segments: const [
                    ButtonSegment(value: TransactionType.expense, label: Text('Expense')),
                    ButtonSegment(value: TransactionType.income, label: Text('Income')),
                  ],
                  selected: {_type},
                  onSelectionChanged: (value) {
                    final newType = value.first;
                    setState(() {
                      _type = newType;
                      _category = newType == TransactionType.expense
                          ? expenseCategories.first
                          : incomeCategories.first;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) => value == null || value.isEmpty ? 'Enter title' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount'),
                  validator: (value) => value == null || value.isEmpty ? 'Enter amount' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  items: categories
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _category = value ?? categories.first),
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Date'),
                  subtitle: Text('${_date.toLocal()}'.split(' ')[0]),
                  trailing: TextButton(onPressed: _pickDate, child: const Text('Pick')),
                ),
                const SizedBox(height: 12),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _recurring,
                  onChanged: (value) => setState(() => _recurring = value),
                  title: const Text('Repeat monthly'),
                  subtitle: const Text('Auto-add this entry each month.'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pushNamed(ReceiptScanScreen.routeName),
                  icon: const Icon(Icons.document_scanner_outlined),
                  label: const Text('Scan receipt (coming soon)'),
                ),
                const SizedBox(height: 24),
                PrimaryButton(label: 'Save entry', onPressed: _save),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
