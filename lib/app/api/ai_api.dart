class ApiConfig {
  static const String url = '3aab-2001-ee0-4b77-4f0-c00b-b0fb-8bac-81f9.ngrok-free.app';
  static const String baseHttpUrl = 'https://$url';
  static const String baseWsUrl = 'wss://$url';
  

  static const String predictEndpoint = '$baseHttpUrl/predict';
  static const String websocketEndpoint = '$baseWsUrl/ws';
  static const String pronunciationCheckEndpoint = '$baseHttpUrl/pronunciation';
  static const String generateSentenceEndpoint = '$baseHttpUrl/generate';
  static const String audioEndpoint = '$baseHttpUrl/audio';
  static const String rootEndpoint = '$baseHttpUrl/';
}
