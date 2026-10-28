import 'package:mqtt_client/mqtt_client.dart';

MqttClient createMqttClient({
  required String host,
  required String clientId,
  required int tcpPort,
  required int wsPort,
  String wsPath = '/mqtt',
}) =>
    throw UnsupportedError('Plataforma não suportada');
