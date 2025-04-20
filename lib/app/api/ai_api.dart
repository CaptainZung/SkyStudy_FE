class ApiConfig {
  static const String url = '88e2-2402-9d80-417-30c1-dc7-83e6-4434-da82.ngrok-free.app';
  static const String baseHttpUrl = 'https://$url';
  static const String baseWsUrl = 'wss://$url';
  

  static const String predictEndpoint = '$baseHttpUrl/predict';
  static const String websocketEndpoint = '$baseWsUrl/ws';
  static const String pronunciationCheckEndpoint = '$baseHttpUrl/pronunciation';
  static const String generateSentenceEndpoint = '$baseHttpUrl/generate';
  static const String audioEndpoint = '$baseHttpUrl/audio';
  static const String rootEndpoint = '$baseHttpUrl/';
}
