import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

class MqttConfig {
  final String server;
  final int port;
  final String username;
  final String password;
  final String topic;
  final String certPath;

  MqttConfig({
    required this.server,
    required this.port,
    required this.username,
    required this.password,
    required this.topic,
    required this.certPath,
  });

  static Future<MqttConfig?> load() async {
    try {
      final configPath = 'assets/config/emqx.env';
      debugPrint('Loading MQTT config from: $configPath');

      final configContent = await rootBundle.loadString(configPath);
      final lines = LineSplitter.split(configContent);

      final config = Map.fromEntries(
        lines
            .map((line) {
              if (line.trim().startsWith('//') || line.trim().isEmpty) {
                return MapEntry('', '');
              }
              final parts = line.split('=');
              return MapEntry(parts[0].trim(), parts[1].trim());
            })
            .where((entry) => entry.key.isNotEmpty),
      );

      final server = config['MQTT_SERVER'];
      final portStr = config['MQTT_PORT'];
      final username = config['MQTT_USER'];
      final password = config['MQTT_PASS'];
      final topic = config['MQTT_TOPIC'];

      if ([server, portStr, username, password, topic].contains(null)) {
        debugPrint('Missing required MQTT configuration values');
        return null;
      }

      final port = int.tryParse(portStr!);
      if (port == null) {
        debugPrint('Invalid port number in configuration');
        return null;
      }

      final certPath = 'assets/config/emqxsl-ca.crt';

      return MqttConfig(
        server: server!,
        port: port,
        username: username!,
        password: password!,
        topic: topic!,
        certPath: certPath,
      );
    } catch (e) {
      debugPrint('Error loading MQTT config: $e');
      return null;
    }
  }
}