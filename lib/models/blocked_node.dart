class BlockedNode {
  final String id;
  final String name;
  final DateTime blockedAt;

  const BlockedNode({
    required this.id,
    required this.name,
    required this.blockedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'blockedAt': blockedAt.toIso8601String(),
      };

  factory BlockedNode.fromJson(Map<String, dynamic> json) => BlockedNode(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? 'Unknown',
        blockedAt: DateTime.tryParse(json['blockedAt'] as String? ?? '') ??
            DateTime.now(),
      );
}
