class DuplicateCache {
  final int maxSize;
  final Set<String> _ids = {};

  DuplicateCache({this.maxSize = 4096});

  bool firstSeen(String id) {
    if (_ids.contains(id)) return false;
    _ids.add(id);
    if (_ids.length > maxSize) _ids.remove(_ids.first);
    return true;
  }
}
