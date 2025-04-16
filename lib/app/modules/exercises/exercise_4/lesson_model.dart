class Exercise4Model {
  final int lessonId;
  final String type;
  final String word;
  final List<String> options;
  final String correctAnswer;

  Exercise4Model({
    required this.lessonId,
    required this.type,
    required this.word,
    required this.options,
    required this.correctAnswer,
  });

  factory Exercise4Model.fromJson(Map<String, dynamic> json) {
    return Exercise4Model(
      lessonId: json['lesson_id'],
      type: json['type'],
      word: json['word'],
      options: List<String>.from(json['options']),
      correctAnswer: json['correct_answer'],
    );
  }
}
