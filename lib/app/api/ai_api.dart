class ApiConfig {
  static const String url = 'c5b0-2001-ee0-4b77-4f0-4d52-5f3e-4cb0-744a.ngrok-free.app';
  static const String baseHttpUrl = 'https://$url';
  static const String baseWsUrl = 'wss://$url';
  

  static const String predictEndpoint = '$baseHttpUrl/predict';
  static const String websocketEndpoint = '$baseWsUrl/ws';
  static const String pronunciationCheckEndpoint = '$baseHttpUrl/pronunciation';
  static const String generateSentenceEndpoint = '$baseHttpUrl/generate';
  static const String audioEndpoint = '$baseHttpUrl/audio';
  static const String rootEndpoint = '$baseHttpUrl/';
}
