class LessonModel {
  final int lessonId;
  final String type;
  final String sound;
  final List<String> options;
  final String correctAnswer;
 
  LessonModel({
    required this.lessonId,
    required this.type,
    required this.sound,
    required this.options,
    required this.correctAnswer,
  });
 
  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      lessonId: json['lesson_id'],
      type: json['type'],
      sound: json['sound'],
      options: List<String>.from(json['options']),
      correctAnswer: json['correct_answer'],
    );
  }
}