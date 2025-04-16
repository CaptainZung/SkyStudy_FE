// lib/app/modules/dictionary/dictionary_model.dart
class Dictionary {
  final int dictionaryId;
  final String word;
  final String ipa;
  final String wordType;
  final String vietnamese;
  final String examples;           // Thêm trường examples
  final String examplesVietnamese;
  final String topic;

  Dictionary({
    required this.dictionaryId,
    required this.word,
    required this.ipa,
    required this.wordType,
    required this.vietnamese,
    required this.examples,           // Thêm vào constructor
    required this.examplesVietnamese,
    required this.topic,
  });

  factory Dictionary.fromJson(Map<String, dynamic> json) {
    return Dictionary(
      dictionaryId: json['dictionary_id'] as int,
      word: json['word'] as String,
      ipa: json['ipa'] as String,
      wordType: json['word_type'] as String,
      vietnamese: json['vietnamese'] as String,
      examples: json['examples'] as String,               // Thêm parse examples
      examplesVietnamese: json['examples_vietnamese'] as String,
      topic: json['topic'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dictionary_id': dictionaryId,
      'word': word,
      'ipa': ipa,
      'word_type': wordType,
      'vietnamese': vietnamese,
      'examples': examples,               // Thêm vào toJson
      'examples_vietnamese': examplesVietnamese,
      'topic': topic,
    };
  }
}