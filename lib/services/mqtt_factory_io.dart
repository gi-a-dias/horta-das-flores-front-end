// Android / iOS / desktop: TCP + TLS puro (porta 8883)
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

MqttClient createMqttClient({
  required String host,
  required String clientId,
  required int tcpPort,
  required int wsPort,
  String wsPath = '/mqtt',
}) {
  final client = MqttServerClient.withPort(host, clientId, tcpPort);
  client.secure = true; // TLS; certificado público (ISRG/Let's Encrypt) já é confiável
  return client;
}
