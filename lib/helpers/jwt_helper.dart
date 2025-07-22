import 'dart:convert';

class JwtHelper {
  static Map<String, dynamic> decodePayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Token inválido');
    }

    final payload = base64.normalize(parts[1]);
    final payloadMap = json.decode(utf8.decode(base64Url.decode(payload)));

    if (payloadMap is! Map<String, dynamic>) {
      throw Exception('Payload inválido');
    }

    return payloadMap;
  }
}
