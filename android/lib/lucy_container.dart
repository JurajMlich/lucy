import 'package:android/database/database_migrations.dart';
import 'package:android/exception/illegal_state_exception.dart';
import 'package:android/repository/finance_deposit_repository.dart';
import 'package:android/repository/finance_transaction_repository.dart';
import 'package:android/repository/resolved_instruction_repository.dart';
import 'package:android/repository/finance_transaction_category_repository.dart';
import 'package:android/repository/unsent_change_repository.dart';
import 'package:android/repository/user_repository.dart';
import 'package:android/service/notification/notification_service.dart';
import 'package:android/synchronization/service/finance_deposit_sync_service.dart';
import 'package:android/synchronization/service/finance_transaction_category_sync_service.dart';
import 'package:android/synchronization/service/finance_transaction_sync_service.dart';
import 'package:android/synchronization/service/user_sync_service.dart';
import 'package:android/synchronization/sync_manager.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class LucyContainer {
  static final LucyContainer _container = LucyContainer._internal();

  SharedPreferences _sharedPreferences;

  SharedPreferences get sharedPreferences => _sharedPreferences;

  Map<Type, dynamic> _services;
  Map<Type, dynamic> _repositories;
  Database _database;

  SyncManager _syncManager;

  SyncManager get syncManager => _syncManager;

  LucyContainer._internal();

  factory LucyContainer() {
    return _container;
  }

  Future<Null> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    _database = await _prepareDatabase();

    _repositories = Map();
    _repositories[UserRepository] = UserRepository(_database);
    _repositories[FinanceDepositRepository] = FinanceDepositRepository(_database);
    _repositories[FinanceTransactionRepository] =
        FinanceTransactionRepository(_database);
    _repositories[FinanceTransactionCategoryRepository] =
        FinanceTransactionCategoryRepository(_database);
    _repositories[ResolvedInstructionRepository] =
        ResolvedInstructionRepository(_database);
    _repositories[PendingChangeRepository] = PendingChangeRepository(_database);

    _services = Map();
    _services[NotificationService] = NotificationService();

    _syncManager = _prepareSyncManager();
  }

  T getRepository<T>() {
    if (!_repositories.containsKey(T)) {
      throw IllegalStateException('Service not found');
    }
    return _repositories[T] as T;
  }

  T getService<T>() {
    if (!_services.containsKey(T)) {
      throw IllegalStateException('Service not found');
    }
    return _services[T] as T;
  }

  Future<T> transaction<T>(
    Future<T> action(Transaction txn), {
    bool exclusive,
  }) {
    return _database.transaction(action);
  }

  Future<Database> _prepareDatabase() async {
    final appDir = await getApplicationDocumentsDirectory();
    final database = await openDatabase(
        join(
          appDir.path,
          'database.db',
        ),
        version: 1,
        onConfigure: (db) async => await db.execute("PRAGMA foreign_keys = ON"),
        onUpgrade: (db, oldVersion, newVersion) => null,
        onCreate: (db, version) async {
          var migrations = buildMigrations(newVersion: version);
          for (var query in migrations) {
            await db.execute(query);
          }
        });
    return database;
  }

  SyncManager _prepareSyncManager() {
    return SyncManager(
      _sharedPreferences,
      _services[NotificationService],
      _repositories[ResolvedInstructionRepository],
      [
        UserSyncService(_repositories[UserRepository]),
        FinanceDepositSyncService(
          _repositories[FinanceDepositRepository],
          _repositories[UserRepository],
        ),
        FinanceTransactionCategorySyncService(
          _repositories[FinanceTransactionCategoryRepository],
        ),
        FinanceTransactionSyncService(
          _repositories[FinanceDepositRepository],
          _repositories[UserRepository],
          _repositories[FinanceTransactionRepository],
          _repositories[FinanceTransactionCategoryRepository],
        )
      ],
    );
  }
}
