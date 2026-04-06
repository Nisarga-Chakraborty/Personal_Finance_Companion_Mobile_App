import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:assignment/database/app_database.dart';
import 'package:assignment/database/transaction_repository.dart';
import 'package:assignment/database/user_repository.dart';
import 'package:assignment/database/home_state.dart';
import 'package:assignment/database/transaction.dart' as database;
import 'package:assignment/database/user.dart';

// 1. opens the database once for the entire app
final databaseProvider = FutureProvider<Database>((ref) async {
  return AppDatabase.getInstance();
});

// 2. creates the repository using the database
final repositoryProvider = FutureProvider<TransactionRepository>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  return TransactionRepository(db);
});

// 3. calls loadHomeData() and exposes HomeState to the home screen
final homeStateProvider = FutureProvider<HomeState>((ref) async {
  final repo = await ref.watch(repositoryProvider.future);
  return repo.loadHomeData();
});
// calls getAllTransactions() and exposes Transaction to the Transaction Screen
final allTransactionsProvider = FutureProvider<List<database.Transaction>>((
  ref,
) async {
  final repo = await ref.watch(repositoryProvider.future);
  return repo.getAllTransactions();
});

// User repository provider
final userRepositoryProvider = FutureProvider<UserRepository>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  return UserRepository(db);
});

// User provider
final userProvider = FutureProvider<User>((ref) async {
  final userRepo = await ref.watch(userRepositoryProvider.future);
  return userRepo.getUser();
});

// Categories provider
final categoriesProvider = FutureProvider<List<String>>((ref) async {
  final userRepo = await ref.watch(userRepositoryProvider.future);
  return userRepo.getCategories();
});
