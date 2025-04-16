class LessonModel {
  final int lessonId;
  final String type;
  final String word;
  final String sound;

  LessonModel({
    required this.lessonId,
    required this.type,
    required this.word,
    required this.sound,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      lessonId: json['lesson_id'],
      type: json['type'],
      word: json['word'],
      sound: json['sound'],
    );
  }
}
