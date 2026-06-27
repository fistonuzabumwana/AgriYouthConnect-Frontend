/// SyncRepository contract defining data synchronization operations.
abstract class SyncRepository {
  /// Check local caches and push any dirty/unsynced farmer profile edits to Node.js backend
  Future<void> triggerOfflineSync();
}
