import 'package:android/repository/repository.dart';
import 'package:android/repository/user_repository.dart';
import 'package:android/synchronization/executor/sync_executor.dart';
import 'package:android/synchronization/executor/user_sync_executor.dart';
import 'package:http/http.dart';
import 'package:sqflite/sqflite.dart';

class SyncManager {
  final Map<String, SyncExecutor> _executors;
  final List<Repository> _repositories;

  SyncManager(Database database)
      : _repositories = [],
        _executors = {} {
    var userRepository = UserRepository(database);

    _repositories.add(userRepository);
    _executors["user"] = UserSyncExecutor(userRepository);
  }

  Future<Null> synchronize() async {
    // todo: decide whether to do incremental or full sync
    // todo: zakaz beh dvoch naraz
    await _Synchronization(this).execute(false);
  }
}

// todo: FULL SYNC MUSI DOBEHNUT CELY, INAK NEPOVOLIT INKREMENTALNY
// todo: PRI INKREMENTALNOM MOZU SPADNUT NIEKTORE COMMANDY, takze by bolo fajn mat tabulku, kde bude stav spracovania commandu... aby ak to spadne uprostred, tak pri opetovnom spusteni to preslo
// todo: pri spracovani toho refresh commandu teda updatnut stav

class _Synchronization {
  SyncManager _syncManager;
  Map<String, List<_EntityDownloadStatus>> entitiesToDownload = {};

  _Synchronization(this._syncManager);

  Future<Null> execute(bool incremental) async {
    final client = Client();

    // todo: last sync time
    // toto musi byt pred _downloadAllData()
    var since = incremental ? DateTime.now() : DateTime.now();

    if (!incremental) {
      await _clearData();
      await _downloadAllData(client);
    } else {
      await _sendInstructions(client);
    }

    var to = DateTime.now();
    // todo: spracovanie inštrukcii z minulého syncu
    await _downloadAndExecuteInstructions(client, since, to);
    since = to;

    while (entitiesToDownload.length > 0) {
      try {
        await _downloadFailedEntities(client);

        if (entitiesToDownload.length == 0) {
          await _sendInstructions(client);
          await _downloadAndExecuteInstructions(client, since, to);
          since = to;
        }
      } catch (e) {
        // todo an exception is thrown only if there is nothing to be downloaded
        to = DateTime.now();
        await _downloadAndExecuteInstructions(client, since, to);
        since = to;
        await _downloadFailedEntities(client);
      }
    }

    // todo: save to as last sync time
  }

  Future<Null> _downloadFailedEntities(Client client) async {
    // todo prejdem vsetky entity ktore na nicom nezavisia
    // a stiahnem ich
    // ak nie je ziadna, tak thrownem exception
  }

  Future<Null> _downloadAllData(Client client) async {
    _syncManager._executors.forEach((resourceName, executor) async {
      final ids = await executor.downloadIds(client);

      var pages = 0;
      var page = 0;
      do {
        var result = await executor.downloadData(client, page);

        result.content.forEach((item) async {
          try {
            await executor.process(item);
            // todo mark as processed
          } catch (e) {
            // fixme
          }
        });

        pages = result.totalPages;
        page++;
      } while (page < pages);

      // todo find not processed and save them (build some intelligent dependency map)
    });
  }

  Future<Null> _clearData() async {
    _syncManager._repositories.forEach((repository) async {
      await repository.deleteAll();
    });
  }

  Future<dynamic> _downloadAndExecuteInstructions(
      Client client, DateTime since, DateTime to) async {
    // todo download all commands...
    // if refresh, add it to special table
    // download the item and parse it
    // if error, add it to entities
    // if success, set state in the special table to success
  }

  Future<Null> _sendInstructions(Client client) async {
    // todo send each instruction to corresponding REST endpoint
  }
}

class _EntityDownloadStatus {
  String type;
  String data;
  dynamic id;
  List<_EntityDownloadStatus> requiredEntities;
  List<_EntityDownloadStatus> beingRequiredBy;

  _EntityDownloadStatus(
      this.type, this.data, this.requiredEntities, this.beingRequiredBy);
}
