class ApiConfig {
  static const String url = 'f9a5-2402-9d80-44a-8976-803b-1f10-5d82-b115.ngrok-free.app';
  static const String baseHttpUrl = 'https://$url';
  static const String baseWsUrl = 'wss://$url';
  

  static const String predictEndpoint = '$baseHttpUrl/predict';
  static const String websocketEndpoint = '$baseWsUrl/ws';
  static const String pronunciationCheckEndpoint = '$baseHttpUrl/pronunciation';
  static const String generateSentenceEndpoint = '$baseHttpUrl/generate';
  static const String audioEndpoint = '$baseHttpUrl/audio';
  static const String rootEndpoint = '$baseHttpUrl/';
}
