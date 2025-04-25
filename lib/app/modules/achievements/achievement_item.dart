import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skystudy/app/modules/achievements/achievements_controller.dart';
import 'package:skystudy/app/modules/achievements/achivement_model.dart';

class AchievementItem extends StatefulWidget {
  final Achievement achievement;

  const AchievementItem({super.key, required this.achievement});

  @override
  State<AchievementItem> createState() => _AchievementItemState();
}

class _AchievementItemState extends State<AchievementItem> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _hasTriggeredAnimation = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    if (widget.achievement.statusClaim == 'complete' && widget.achievement.sticker != null) {
      _hasTriggeredAnimation = true;
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(AchievementItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.achievement.statusClaim == 'complete' &&
        widget.achievement.sticker != null &&
        !_hasTriggeredAnimation) {
      _hasTriggeredAnimation = true;
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AchievementsController>(tag: 'AchievementsController');
    final progressParts = (widget.achievement.progress ?? '0/1').split('/');
    final progress = int.tryParse(progressParts[0]) ?? 0;
    final total = int.tryParse(progressParts[1]) ?? 1;
    final reward = 10;

    final bool showSticker = widget.achievement.statusClaim == 'complete' &&
        widget.achievement.sticker != null &&
        widget.achievement.sticker!.isNotEmpty &&
        Uri.tryParse(widget.achievement.sticker!)?.hasScheme == true;

    Color cardColor;
    if (widget.achievement.status == 'complete' && widget.achievement.statusClaim == 'incomplete') {
      cardColor = Colors.green[100]!;
    } else if (widget.achievement.status == 'complete' && widget.achievement.statusClaim == 'complete') {
      cardColor = Colors.yellow[100]!;
    } else {
      cardColor = Colors.grey[200]!;
    }

    return Card(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.achievement.name ?? 'Không có tiêu đề',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.achievement.progress ?? '0/1',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: total == 0 ? 0 : progress / total,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  if (showSticker) ...[
                    const SizedBox(height: 8),
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Image.network(
                        widget.achievement.sticker!,
                        width: 50,
                        height: 50,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Row(
              children: [
                if (widget.achievement.status == 'complete' && widget.achievement.statusClaim == 'incomplete')
                  ElevatedButton(
                    onPressed: () async {
                      await controller.claimAchievement(widget.achievement.id);
                    },
                    child: const Text('Nhận thưởng'),
                  )
                else
                  Row(
                    children: [
                      Image.asset(
                        'assets/icons/point.png',
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+$reward',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}