import '../models/connection.dart';
import '../models/user.dart';

class UserService {
  Future<int> addUser(User user) async {
    final db = await DatabaseConnection.instance.database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUser(String username, String password) async {
    final db = await DatabaseConnection.instance.database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }
}
