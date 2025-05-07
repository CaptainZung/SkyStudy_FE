class Sticker {
  final String name;
  final String stickerUrl;

  Sticker({required this.name, required this.stickerUrl});

  factory Sticker.fromJson(Map<String, dynamic> json) {
    return Sticker(
      name: json['name'] ?? 'Không có tên',
      stickerUrl: json['sticker'] ?? '',
    );
  }
}