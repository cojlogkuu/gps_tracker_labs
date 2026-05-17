import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart';

MqttClient setupMqttClient(String broker) {
  final client = MqttBrowserClient(
    broker.startsWith('ws') ? broker : 'ws://$broker',
    'client_${DateTime.now().millisecondsSinceEpoch}',
  );
  // Note: HiveMQ public websocket port is actually 8000,
  // but using 9001 locally.
  client.port = 9001;
  client.setProtocolV311();
  client.websocketProtocols = MqttClientConstants.protocolsSingleDefault;
  return client;
}
