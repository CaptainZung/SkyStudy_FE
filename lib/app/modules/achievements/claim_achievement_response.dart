import 'package:skystudy/app/modules/achievements/achivement_model.dart';

class ClaimAchievementResponse {
  final Achievement achievement;

  ClaimAchievementResponse({required this.achievement});

  factory ClaimAchievementResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {'achievement_id': 0};
    return ClaimAchievementResponse(
      achievement: Achievement.fromJson({
        'achievement_id': data['achievement_id'],
        'name': data['name'] ?? 'Không có tiêu đề',
        'type': data['type'] ?? 'Không xác định',
        'progress': data['progress'] ?? '0/1',
        'status': data['status'] ?? 'incomplete',
        'status_claim': data['status'] == 'complete' ? 'complete' : 'incomplete',
        'achievement_sticker': data['achievement_sticker'],
      }),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': achievement.toJson(),
    };
  }
}