import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/balance_service.dart';

class ExpensesPage extends StatefulWidget {
  final int userId;

  ExpensesPage({required this.userId});

  @override
  _ExpensesPageState createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final BalanceService _balanceService = BalanceService();
  DateTime _selectedDate = DateTime.now();

  void _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  void _saveExpense() async {
    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;

    if (title.isNotEmpty && amount > 0) {
      try {
        await _balanceService.addExpense(
          widget.userId,
          title,
          amount,
          DateFormat('yyyy-MM-dd').format(_selectedDate),
        );
        Navigator.pop(context);
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('Failed to save expense: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Invalid Input'),
          content: Text('Please enter valid title and amount.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Expense')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Amount [PLN]'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Text('Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
                Spacer(),
                TextButton(
                  onPressed: _pickDate,
                  child: Text('Pick Date'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _saveExpense,
                  child: Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
