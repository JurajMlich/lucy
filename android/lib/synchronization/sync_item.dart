/// Type of item that is being synchronized with server.
enum SyncItemType {
  user,
  financeDeposit,
  financeTransaction,
  financeTransactionCategory,
}

/// State of refresh.
enum SyncItemRefreshResultState {
  errorOccurred,
  referenceMissing,
  refreshed,
}

/// Item that is being synchronized with server. Has overridden hashCode and
/// ==, so two items with identical types and ids have the same hashCode and id.
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
  int get hashCode => type.hashCode ^ id.hashCode;
}

/// Result of refresh action of an item.
class SyncItemRefreshResult {
  /// Item attempted to be refreshed.
  SyncItem item;

  /// State of refresh.
  SyncItemRefreshResultState state;

  /// In case of refresh being unsuccessful as some other items need to be
  /// refreshed, these are the other items.
  Set<SyncItem> missingReferences;

  SyncItemRefreshResult(
    this.item,
    this.state,
    this.missingReferences,
  );
}
