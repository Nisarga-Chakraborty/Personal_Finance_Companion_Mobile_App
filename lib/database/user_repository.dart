import 'package:sqflite/sqflite.dart';
import 'package:assignment/database/user.dart';
import 'package:uuid/uuid.dart';

class UserRepository {
  final Database db;

  UserRepository(this.db);

  // Get or create default user
  Future<User> getUser() async {
    final result = await db.query('users', limit: 1);
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    // Create default user if none exists
    final defaultUser = User(
      id: const Uuid().v4(),
      name: 'User',
      age: 25,
      gender: 'Other',
      monthlyBudget: 10000,
      currency: '₹',
    );
    await db.insert('users', defaultUser.toMap());
    return defaultUser;
  }

  // Update user
  Future<void> updateUser(User user) async {
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Delete all data for categories
  Future<List<String>> getCategories() async {
    final result = await db.rawQuery(
      'SELECT DISTINCT category FROM transactions ORDER BY category',
    );
    return result.map((e) => e['category'] as String).toList();
  }
}
