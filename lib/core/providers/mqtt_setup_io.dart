import 'dart:io';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

MqttClient setupMqttClient() {
  final broker = Platform.isAndroid ? '10.0.2.2' : '127.0.0.1';
  final client = MqttServerClient(
    broker,
    'client_${DateTime.now().millisecondsSinceEpoch}',
  );
  client.port = 1883;
  return client;
}
