import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/balance_service.dart';
import '../services/weather_service.dart';
import 'expenses.dart';
import 'incomes.dart';
import 'login.dart';

class BalancePage extends StatefulWidget {
  final int userId;

  BalancePage({required this.userId});

  @override
  _BalancePageState createState() => _BalancePageState();
}

class _BalancePageState extends State<BalancePage> {
  final BalanceService _balanceService = BalanceService();
  final WeatherService _weatherService = WeatherService();

  List<Map<String, dynamic>> _expenses = [];
  List<Map<String, dynamic>> _incomes = [];
  double _balance = 0.0;
  String _weatherInfo = "Loading weather...";

  @override
  void initState() {
    super.initState();
    _fetchData();
    _fetchWeather();
  }

  Future<void> _fetchData() async {
    final expenses = await _balanceService.getExpenses(widget.userId);
    final incomes = await _balanceService.getIncomes(widget.userId);

    final expenseTotal = expenses.fold(0.0, (sum, e) => sum + e['amount']);
    final incomeTotal = incomes.fold(0.0, (sum, i) => sum + i['amount']);

    setState(() {
      _expenses = expenses;
      _incomes = incomes;
      _balance = incomeTotal - expenseTotal;
    });
  }

  Future<void> _fetchWeather() async {
    final weather = await _weatherService.getCurrentWeather();
    setState(() => _weatherInfo = weather);
  }

  void _editItem(BuildContext context, Map<String, dynamic> item, bool isIncome) {
    final _titleController = TextEditingController(text: item['title']);
    final _amountController =
    TextEditingController(text: item['amount'].toString());
    DateTime _selectedDate = DateTime.parse(item['date']);

    void _pickDate() async {
      final pickedDate = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (pickedDate != null) {
        _selectedDate = pickedDate;
      }
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isIncome ? 'Edit Income' : 'Edit Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Amount (€)'),
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final title = _titleController.text.trim();
              final amount =
                  double.tryParse(_amountController.text.trim()) ?? 0.0;

              if (title.isNotEmpty && amount > 0) {
                Navigator.pop(context);
                if (isIncome) {
                  await _balanceService.updateIncome(
                    item['id'],
                    title,
                    amount,
                    DateFormat('yyyy-MM-dd').format(_selectedDate),
                  );
                } else {
                  await _balanceService.updateExpense(
                    item['id'],
                    title,
                    amount,
                    DateFormat('yyyy-MM-dd').format(_selectedDate),
                  );
                }
                _fetchData();
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteItem(int id, bool isIncome) async {
    if (isIncome) {
      await _balanceService.deleteIncome(id);
    } else {
      await _balanceService.deleteExpense(id);
    }
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final balanceColor = _balance >= 0 ? Colors.blue : Colors.red;

    return Scaffold(
      appBar: AppBar(
        title: Text('Balance'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
                    (route) => false,
              );
            },
            tooltip: 'Log Off',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Weather: $_weatherInfo",
              style: TextStyle(fontSize: 16),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text('Incomes', style: TextStyle(fontSize: 18)),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _incomes.length,
                          itemBuilder: (context, index) {
                            final income = _incomes[index];
                            return ListTile(
                              title: Text(income['title']),
                              subtitle: Text(income['date']),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () =>
                                        _editItem(context, income, true),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () =>
                                        _deleteItem(income['id'], true),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    IncomesPage(userId: widget.userId)),
                          ).then((_) => _fetchData());
                        },
                        child: Text('Add Income'),
                      ),
                    ],
                  ),
                ),
                VerticalDivider(),
                Expanded(
                  child: Column(
                    children: [
                      Text('Expenses', style: TextStyle(fontSize: 18)),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _expenses.length,
                          itemBuilder: (context, index) {
                            final expense = _expenses[index];
                            return ListTile(
                              title: Text(expense['title']),
                              subtitle: Text(expense['date']),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () =>
                                        _editItem(context, expense, false),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () =>
                                        _deleteItem(expense['id'], false),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ExpensesPage(userId: widget.userId)),
                          ).then((_) => _fetchData());
                        },
                        child: Text('Add Expense'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          FloatingActionButton.extended(
            backgroundColor: balanceColor,
            label: Text(
              'Balance: €${_balance.toStringAsFixed(2)}',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
