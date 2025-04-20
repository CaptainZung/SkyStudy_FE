import 'package:get/get.dart';

class AchievementsController extends GetxController {
  final List<Map<String, dynamic>> achievements = [
    {'title': 'Học 5 từ', 'progress': 0, 'total': 5, 'reward': 10},
    {'title': 'Học 10 từ', 'progress': 0, 'total': 10, 'reward': 20},
    {'title': 'Học 30 từ', 'progress': 0, 'total': 30, 'reward': 60},
    {'title': 'Học 5 câu', 'progress': 5, 'total': 5, 'reward': 5},
  ];

  final List<Map<String, dynamic>> dailyTasks = [
    {'title': 'Học 5 từ', 'progress': 5, 'total': 5, 'reward': 10},
    {'title': 'Học 10 từ', 'progress': 10, 'total': 10, 'reward': 20},
    {'title': 'Học 30 từ', 'progress': 30, 'total': 30, 'reward': 60},
    {'title': 'Học 5 câu', 'progress': 5, 'total': 5, 'reward': 5},
  ];
}