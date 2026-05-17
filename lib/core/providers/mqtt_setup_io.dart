import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

MqttClient setupMqttClient(String broker) {
  final client = MqttServerClient(
    broker,
    'client_${DateTime.now().millisecondsSinceEpoch}',
  );
  client.port = 1883;
  return client;
}
