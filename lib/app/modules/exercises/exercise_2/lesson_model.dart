class LessonModel {
  final int lessonId;
  final String type;
  final String image;  // Thêm trường 'image' cho bài học
  final List<String> options;
  final String correctAnswer;

  LessonModel({
    required this.lessonId,
    required this.type,
    required this.image,
    required this.options,
    required this.correctAnswer,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      lessonId: json['lesson_id'],
      type: json['type'],
      image: json['image'],  // Lấy 'image' từ dữ liệu JSON
      options: List<String>.from(json['options']),
      correctAnswer: json['correct_answer'],
    );
  }
}
