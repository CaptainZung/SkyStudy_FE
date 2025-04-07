class ApiConfig {
  static const String baseHttpUrl = 'https://c961-14-236-18-153.ngrok-free.app';
  static const String baseWsUrl = 'wss://c961-14-236-18-153.ngrok-free.app';
  

  static const String predictEndpoint = '$baseHttpUrl/predict';
  static const String websocketEndpoint = '$baseWsUrl/ws';
  static const String pronunciationCheckEndpoint = '$baseHttpUrl/pronunciation';
  static const String generateSentenceEndpoint = '$baseHttpUrl/generate';
  static const String audioEndpoint = '$baseHttpUrl/audio';
  static const String rootEndpoint = '$baseHttpUrl/';
}
