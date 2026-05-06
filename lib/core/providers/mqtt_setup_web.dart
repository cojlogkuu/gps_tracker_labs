import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart';

MqttClient setupMqttClient() {
  final client = MqttBrowserClient(
    'ws://127.0.0.1',
    'client_${DateTime.now().millisecondsSinceEpoch}',
  );
  client.port = 9001;
  client.setProtocolV311();
  client.websocketProtocols = MqttClientConstants.protocolsSingleDefault;
  return client;
}
