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
  late Animation<Color?> _colorAnimation;
  bool _hasTriggeredAnimation = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _colorAnimation = ColorTween(
      begin: Colors.grey[200],
      end: Colors.blue[50],
    ).animate(_animationController);
    
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
      cardColor = Colors.green[50]!;
    } else if (widget.achievement.status == 'complete' && widget.achievement.statusClaim == 'complete') {
      cardColor = Colors.amber[50]!;
    } else {
      cardColor = Colors.grey[100]!;
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: _colorAnimation.value ?? cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status indicator
                Container(
                  width: 4,
                  height: 60,
                  decoration: BoxDecoration(
                    color: widget.achievement.status == 'complete'
                        ? widget.achievement.statusClaim == 'complete'
                            ? Colors.amber
                            : Colors.green
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.achievement.name ?? 'Không có tiêu đề',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          if (widget.achievement.status == 'complete' && 
                              widget.achievement.statusClaim == 'complete')
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle, color: Colors.amber[700], size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Đã nhận',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.amber[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Progress text with percentage
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '$progress/$total (${((progress/total)*100).toStringAsFixed(0)}%)',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          if (widget.achievement.status == 'complete')
                            Row(
                              children: [
                                Image.asset(
                                  'assets/icons/point.png',
                                  width: 16,
                                  height: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '+$reward',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700],
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: total == 0 ? 0 : progress / total,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.achievement.status == 'complete'
                                ? widget.achievement.statusClaim == 'complete'
                                    ? Colors.amber
                                    : Colors.green
                                : Colors.blue,
                          ),
                          minHeight: 8,
                        ),
                      ),
                      if (showSticker) ...[
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.center,
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Image.network(
                                widget.achievement.sticker!,
                                width: 60,
                                height: 60,
                                errorBuilder: (context, error, stackTrace) => 
                                  const Icon(Icons.error, color: Colors.red),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Claim button
                if (widget.achievement.status == 'complete' && 
                    widget.achievement.statusClaim == 'incomplete')
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: ElevatedButton(
                      onPressed: () async {
                        await controller.claimAchievement(widget.achievement.id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Nhận thưởng',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}