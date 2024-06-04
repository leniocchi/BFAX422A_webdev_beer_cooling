import 'dart:io' as io;
import 'dart:convert';


class Config{
  Config({required this.apiToken, required this.organizationId});

  final String apiToken;
  final String organizationId;

  static Future<Config> readConfig() async {
    try {
      var path = io.Directory.current.path;
      print('Current directory: $path');

      var secretsPath = 'secrets.json';
      print('Trying to read: $secretsPath');

      var secrets = await io.File(secretsPath).readAsString();
      print('File contents: $secrets');

      var json = jsonDecode(secrets);
      return Config(
        apiToken: json['api_token'],
        organizationId: json['organization_id'],
      );
    } catch (e) {
      print('Error reading secrets.json: $e');
      rethrow;
    }
  }

}