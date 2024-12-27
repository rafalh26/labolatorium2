import 'package:intl/intl.dart';
import '../models/connection.dart';

class BalanceService {
  Future<void> addExpense(
      int userId, String title, double amount, String date) async {
    final db = await DatabaseConnection.instance.database;

    await db.insert('expenses', {
      'userId': userId,
      'title': title,
      'amount': amount,
      'date': date,
    });
  }

  Future<void> addIncome(
      int userId, String title, double amount, String date) async {
    final db = await DatabaseConnection.instance.database;

    await db.insert('incomes', {
      'userId': userId,
      'title': title,
      'amount': amount,
      'date': date,
    });
  }

  Future<void> updateExpense(int id, String title, double amount, String date) async {
    final db = await DatabaseConnection.instance.database;
    await db.update(
      'expenses',
      {'title': title, 'amount': amount, 'date': date},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateIncome(int id, String title, double amount, String date) async {
    final db = await DatabaseConnection.instance.database;
    await db.update(
      'incomes',
      {'title': title, 'amount': amount, 'date': date},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteExpense(int id) async {
    final db = await DatabaseConnection.instance.database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteIncome(int id) async {
    final db = await DatabaseConnection.instance.database;
    await db.delete('incomes', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getExpenses(int userId) async {
    final db = await DatabaseConnection.instance.database;
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);

    return await db.query(
      'expenses',
      where: 'userId = ? AND date BETWEEN ? AND ?',
      whereArgs: [
        userId,
        DateFormat('yyyy-MM-dd').format(firstDay),
        DateFormat('yyyy-MM-dd').format(lastDay),
      ],
    );
  }

  Future<List<Map<String, dynamic>>> getIncomes(int userId) async {
    final db = await DatabaseConnection.instance.database;
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);

    return await db.query(
      'incomes',
      where: 'userId = ? AND date BETWEEN ? AND ?',
      whereArgs: [
        userId,
        DateFormat('yyyy-MM-dd').format(firstDay),
        DateFormat('yyyy-MM-dd').format(lastDay),
      ],
    );
  }
}
