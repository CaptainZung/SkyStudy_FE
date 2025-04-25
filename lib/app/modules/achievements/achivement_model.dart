class Achievement {
  final int id;
  final String name;
  final String type;
  final String progress;
  final String status;
  final String statusClaim;
  final String? sticker;

  Achievement({
    required this.id,
    required this.name,
    required this.type,
    required this.progress,
    required this.status,
    required this.statusClaim,
    this.sticker,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['achievement_id'] != null
          ? (json['achievement_id'] is String
              ? int.parse(json['achievement_id'])
              : json['achievement_id'] as int)
          : 0,
      name: json['name'] as String? ?? 'Không có tiêu đề',
      type: json['type'] as String? ?? 'Không xác định',
      progress: json['progress'] as String? ?? '0/1',
      status: json['status'] as String? ?? 'incomplete',
      statusClaim: json['status_claim'] as String? ?? 'incomplete',
      sticker: json['achievement_sticker'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'achievement_id': id,
      'name': name,
      'type': type,
      'progress': progress,
      'status': status,
      'status_claim': statusClaim,
      'achievement_sticker': sticker,
    };
  }
}