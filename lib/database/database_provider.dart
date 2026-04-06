// lib/core/database/database_provider.dart

import 'package:assignment/database/transaction_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'app_database.dart';

// This opens the DB once and shares it across the app
final databaseProvider = FutureProvider<Database>((ref) async {
  return AppDatabase.getInstance();
});

// This gives you the repository wherever you need it
final transactionRepositoryProvider = FutureProvider<TransactionRepository>((
  ref,
) async {
  final db = await ref.watch(databaseProvider.future);
  return TransactionRepository(db);
});
