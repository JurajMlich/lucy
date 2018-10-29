enum SyncItemType {
  user,
  deposit,
}

enum SyncItemRefreshResultState {
  toBeSynchronized,
  referenceMissing,
  synchronized,
}

class SyncItem {
  SyncItemType type;
  dynamic id;

  SyncItem(this.type, this.id);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is SyncItem &&
              runtimeType == other.runtimeType &&
              type == other.type &&
              id == other.id;

  @override
  int get hashCode =>
      type.hashCode ^
      id.hashCode;
}

class SyncItemRefreshResult {
  SyncItem item;
  SyncItemRefreshResultState state;
  Set<SyncItem> missingReferences;

  SyncItemRefreshResult(
    this.item,
    this.state,
    this.missingReferences,
  );
}

