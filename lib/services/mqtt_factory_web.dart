// Chrome / Web: navegador só fala WebSocket seguro (WSS)
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';

MqttClient createMqttClient({
  required String host,
  required String clientId,
  required int tcpPort,
  required int wsPort,
  String wsPath = '/mqtt',
}) {
  final client = MqttBrowserClient('wss://$host$wsPath', clientId);
  client.port = wsPort; // EMQX Cloud: 8084 | HiveMQ Cloud: 8884
  return client;
}
