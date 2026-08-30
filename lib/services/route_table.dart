class RouteEntry {
  final String destination;
  final String nextHop;
  final int metric;
  final int sequence;
  final DateTime expiresAt;

  const RouteEntry({
    required this.destination,
    required this.nextHop,
    required this.metric,
    required this.sequence,
    required this.expiresAt,
  });

  bool get expired => DateTime.now().isAfter(expiresAt);
}

class RouteTable {
  final Map<String, RouteEntry> _routes = {};

  bool learn({
    required String destination,
    required String nextHop,
    required int metric,
    int sequence = 0,
    Duration lifetime = const Duration(seconds: 60),
  }) {
    final old = _routes[destination];
    final replace = old == null ||
        old.expired ||
        sequence > old.sequence ||
        (sequence == old.sequence && metric < old.metric);

    if (!replace) return false;

    _routes[destination] = RouteEntry(
      destination: destination,
      nextHop: nextHop,
      metric: metric,
      sequence: sequence,
      expiresAt: DateTime.now().add(lifetime),
    );
    return true;
  }

  String? nextHop(String destination) {
    final r = _routes[destination];
    if (r == null || r.expired) {
      _routes.remove(destination);
      return null;
    }
    return r.nextHop;
  }

  RouteEntry? lookup(String destination) {
    final r = _routes[destination];
    if (r == null || r.expired) {
      _routes.remove(destination);
      return null;
    }
    return r;
  }

  List<RouteEntry> get active {
    _routes.removeWhere((_, v) => v.expired);
    return _routes.values.toList();
  }
}
