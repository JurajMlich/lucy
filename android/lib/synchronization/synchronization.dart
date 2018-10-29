import 'dart:convert';

import 'package:android/config/config.dart';
import 'package:android/exception/illegal_state_exception.dart';
import 'package:android/repository/resolved_instruction_repository.dart';
import 'package:android/synchronization/server_driver.dart';
import 'package:android/synchronization/service/sync_service.dart';
import 'package:android/synchronization/sync_item.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Main unit for synchronization with server. Two modes of synchronization are
/// supported: full and incremental. In full sync, all data are removed using
/// sync services and downloaded again while ensuring data integrity. After full
/// sync, commands are downloaded from server, doing incremental sync if
/// anything changed while full sync in progress.
///
/// To ensure all data are downloaded, the client first downloads ids of all
/// items available. Then downloads items page by page until all pages are
/// downloaded. Changes in ordering may, however, result in some data not
/// downloaded. As we downloaded the ids first, we know what items were not
/// received, thus we can download them individually.
///
/// When everything downloaded (some items may still be not processed due to
/// missing references) or when doing incremental sync, commands are
/// downloaded. They tell us what items have changed. We then try to refresh
/// the data, they tell us that have changed, command by command. Some
/// commands may not be executed immediately as some references may be
/// missing. We internally store graph of these dependencies and try to
/// download items that do not depend on anything first.
///
/// Edge cases are also addressed.
// todo(pull): unauthorized & not found
class Synchronization {
  final Logger _logger = new Logger('Synchronization');

  final SharedPreferences _sharedPreferences;
  final ResolvedInstructionRepository _resolvedInstructionRepository;
  final Map<SyncItemType, SyncService> _serviceToTypeMap;

  final Set<_ItemToRefresh> _itemsToRefresh;

  // note: SyncItem has overridden hashCode and ==, so two items with the
  // same type and id are the same object from the point of view of the map
  final Map<SyncItem, _ItemToRefresh> _itemToWrapperMap;

  Synchronization(
    this._sharedPreferences,
    this._resolvedInstructionRepository,
    List<SyncService> services,
  )   : _itemsToRefresh = Set(),
        _itemToWrapperMap = Map(),
        _serviceToTypeMap = Map() {
    // for fast access
    services.forEach((service) => _serviceToTypeMap[service.forType] = service);
  }

  /// Execute full / incremental sync in the way described in class docs.
  Future<Null> execute(bool incremental) async {
    _logger.info(
      'Starting ${incremental ? 'incremental' : 'full'} synchronization.',
    );
    final client = ServerClient(Config.serverUrl);

    // this must be before _downloadAllData() as we want to download commands
    // that happened while full download in progress.
    DateTime findCommandsSince = DateTime.now();

    // if incremental sync, we want commands only after the last sync
    if (incremental) {
      var lastSyncInt = _sharedPreferences.getInt('lastSync');
      if (lastSyncInt == null) {
        incremental = false;
      }

      findCommandsSince =
          DateTime.fromMillisecondsSinceEpoch(lastSyncInt, isUtc: true);
    }

    if (!incremental) {
      await _clearData();
      await _downloadAllData(client);
    } else {
      // we send instructions first
      await _sendInstructions(client);
    }

    var findCommandsUntil = DateTime.now();
    await _downloadAndExecuteInstructions(
        client, findCommandsSince, findCommandsUntil);
    findCommandsSince = findCommandsUntil;

    // while there are some items that have not been resolved because they
    // either have not arrived or have some missing references
    while (_itemsToRefresh.length > 0) {
      // if something was refreshed
      if (await _refreshFailedItemsWithoutParents(client)) {
        // if finished, send / download instructions may cause new entities
        // to be in need of being refreshed, thus still in the while cycle, not
        // out of it
        if (_itemsToRefresh.length == 0) {
          // we send instructions once more time as something new could have
          // happened and they may cause new server instructions to be
          // downloaded
          //
          // another scenario:
          // 1. item A is changed on server and refresh command is downloaded
          // 2. items A and B change, new refresh commands are generated
          // 3. the first refresh command is executed (however, we get the
          // newest data, not data at the time of command creation)
          // 4. data in item A may be invalid as they require update of item B
          //
          // so at the end of every sync, we download new instructions
          await _sendInstructions(client);
          await _downloadAndExecuteInstructions(
              client, findCommandsSince, findCommandsUntil);
          findCommandsSince = findCommandsUntil;
        }
      } else {
        // if nothing has been resoled, we have a problem as there are only
        // items with missing references to be downloaded... that may happen
        // only in one scenario:
        // 1. if some item was changed and server instruction was generated
        // 2. client downloaded this instruction
        // 3. the item was changed again
        // 4. client downloaded the newest version of item
        //
        // so we need the newest instructions and should be OK
        findCommandsUntil = DateTime.now();
        await _downloadAndExecuteInstructions(
            client, findCommandsSince, findCommandsUntil);
        findCommandsSince = findCommandsUntil;
        await _refreshFailedItemsWithoutParents(client);
      }
    }

    // sync done
    await _sharedPreferences.setInt(
        'lastSync', findCommandsUntil.toUtc().millisecondsSinceEpoch);
    await _resolvedInstructionRepository.clear();
    client.close();
    _logger.info('Synchronization done.');
  }

  /// Refresh failed items without parents. If any change was successful,
  /// return true. Otherwise, return false.
  Future<bool> _refreshFailedItemsWithoutParents(ServerClient client) async {
    _logger.info('Downloading failed entities');
    var atLeastOne = false;

    // method _processRefreshResult modifies the set and set must not be
    // modified while being iterated over, so we iterate over a copy
    var itemsToRefresh = Set.from(_itemsToRefresh);

    for (_ItemToRefresh wrapper in itemsToRefresh) {
      if (wrapper.parents.length == 0) {
        _logger.info(
          'Downloading failed entity ${wrapper.item.type} with id ${wrapper.item.id}.',
        );

        var result = await _serviceToTypeMap[wrapper.item.type]
            .refreshOne(client, wrapper.item.id);

        if (result.state == SyncItemRefreshResultState.refreshed) {
          atLeastOne = true;
        }

        await _processRefreshResult(result);
      }
    }

    return atLeastOne;
  }

  /// Update download graph according to result.
  Future<Null> _processRefreshResult(SyncItemRefreshResult result) async {
    // if item was not successfully synchronized
    if (result.state == SyncItemRefreshResultState.errorOccurred ||
        result.state == SyncItemRefreshResultState.referenceMissing) {
      // logging
      if (result.state == SyncItemRefreshResultState.referenceMissing) {
        var references = result.missingReferences
            .map((item) => item.type.toString() + '(' + item.id + ')')
            .join(", ");

        _logger.info(
          'Download of item ${result.item.type} with id ${result.item.id} '
              'failed. Missing references: '
              '$references}.',
        );
      } else {
        _logger.info(
            'Download of item ${result.item.type} with id ${result.item.id} '
            'failed. Item did not arrive.');
      }

      var wrapper = _getInternalRepresentationOfItem(result.item);

      // we need to reflect result's missing references into the wrapper
      // so we do it hard way - remove old items and add new items
      wrapper.parents.forEach((parent) => wrapper.children.remove(wrapper));
      wrapper.parents = result.missingReferences.map((missingReference) {
        var parent = _getInternalRepresentationOfItem(missingReference);
        parent.children.add(wrapper);
        return parent;
      }).toSet();

      // as the item is still not refreshed, we add it to set of items in
      // need of refresh
      _itemsToRefresh.add(wrapper);
    } else {
      _logger.info(
        'Download of item ${result.item.type} with id ${result.item.id} '
            'successful.',
      );
      // we need to update data only if it is in our internal state
      if (_itemToWrapperMap.containsKey(result.item)) {
        var wrapper = _itemToWrapperMap[result.item];

        // the actions below are crucial as in next iteration, it frees items
        // that depended on it to be refreshed if they have no other references
        wrapper.children.forEach((child) {
          child.parents.remove(wrapper);
        });
        wrapper.parents.forEach((parent) {
          parent.children.remove(wrapper);
        });

        _itemToWrapperMap.remove(wrapper);
        _itemsToRefresh.remove(wrapper);

        // if the item was to be refreshed because of server instruction, we
        // mark that instruction as resolved.
        for (var id in wrapper.instructionIdsToResolve) {
          await _resolvedInstructionRepository.resolve(id);
        }
      }
    }
  }

  /// Invoke refreshAll for every service and process result by
  /// _processRefreshResult.
  Future<Null> _downloadAllData(ServerClient client) async {
    _logger.info('Downloading all data');
    for (SyncService service in _serviceToTypeMap.values) {
      var metadataList = await service.refreshAll(client);

      for (SyncItemRefreshResult action in metadataList) {
        await _processRefreshResult(action);
      }
    }
  }

  /// Clear data (performing full sync).
  Future<Null> _clearData() async {
    _logger.info('Clearing data');
    for (SyncService service in _serviceToTypeMap.values) {
      await service.clearData();
    }
    // todo(push): clear instructions
  }

  /// Download server instructions and execute them only if they have not
  /// been executed already (we know that by ResolvedInstructionRepository,
  /// which stores this information, even though data are cleared as soon as
  /// sync is done). Thus, no action is going to be performed twice even if
  /// the application crashes.
  Future<dynamic> _downloadAndExecuteInstructions(
    ServerClient client,
    DateTime since,
    DateTime to,
  ) async {
    _logger.info('Downloading and executing instructions');
    var response = await client.get(
      'instructions?from=${ServerClient.dateFormat.format(since.toUtc())}'
          '&to=${ServerClient.dateFormat.format(to.toUtc())}',
    );
    var instructions = jsonDecode(response.body) as List<dynamic>;

    // server tells us what resources have changed, but we have SyncItemTypes
    var resourceToSyncItemType = {
      'user': SyncItemType.user,
      'deposit': SyncItemType.deposit
    };

    for (var instruction in instructions) {
      // in case of a crash
      if (await _resolvedInstructionRepository.isResolved(instruction['id'])) {
        continue;
      }

      if (instruction['type'] == 'REFRESH_DATA') {
        var data = jsonDecode(instruction['data']);
        var type = resourceToSyncItemType[data['resource']];

        if (type == null) {
          throw IllegalStateException('REFRESH_DATA instruction wants to '
              'refresh ${data['resource']} but such SyncItemType does not'
              'was not found.');
        }

        var result = await _serviceToTypeMap[type]
            .refreshOne(client, data['identifier']);

        var item = _getInternalRepresentationOfItem(result.item);
        // when the item is refreshed, mark the instruction as resolved
        item.instructionIdsToResolve.add(instruction['id']);

        await _processRefreshResult(result);
      }
    }
  }

  /// Send instructions to server (changes).
  Future<Null> _sendInstructions(ServerClient client) async {
    _logger.info('Sending instructions');
    // todo(push): send each instruction to corresponding REST endpoint
  }

  /// Wrap sync item in wrapper which contains additional info. Always
  /// returns the same object for the same sync item.
  _ItemToRefresh _getInternalRepresentationOfItem(SyncItem item) {
    if (!_itemToWrapperMap.containsKey(item)) {
      _itemToWrapperMap[item] = _ItemToRefresh(item, Set(), Set(), Set());
    }

    return _itemToWrapperMap[item];
  }
}

/// Special internal class containing additional info about an sync item to
/// be refreshed.
class _ItemToRefresh {
  /// What to refresh.
  SyncItem item;

  /// Parents that need to be refreshed first.
  Set<_ItemToRefresh> parents;

  /// Children that depend on this item to be refreshed.
  Set<_ItemToRefresh> children;

  /// When refreshed, this server instructions need to be marked as resolved.
  Set<int> instructionIdsToResolve;

  _ItemToRefresh(
    this.item,
    this.parents,
    this.children,
    this.instructionIdsToResolve,
  );
}
