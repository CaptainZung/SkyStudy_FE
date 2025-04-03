class ApiConfig {
  static const String baseHttpUrl = 'https://6a98-118-69-62-145.ngrok-free.app';
  static const String baseWsUrl = 'wss://6a98-118-69-62-145.ngrok-free.app';

  static const String predictEndpoint = '$baseHttpUrl/predict';
  static const String websocketEndpoint = '$baseWsUrl/ws';
  static const String pronunciationEndpoint = '$baseHttpUrl/pronunciation';
  static const String generateSentenceEndpoint = '$baseHttpUrl/generate';
  static const String audioEndpoint = '$baseHttpUrl/audio';
  static const String rootEndpoint = '$baseHttpUrl/';
}
