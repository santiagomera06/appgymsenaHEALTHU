class ApiConfig {
  static const String baseUrl = 'http://54.227.38.102:8080';

  static String getUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
}
