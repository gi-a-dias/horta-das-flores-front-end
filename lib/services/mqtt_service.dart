import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';

import 'mqtt_factory_stub.dart'
    if (dart.library.io) 'mqtt_factory_io.dart'
    if (dart.library.js_interop) 'mqtt_factory_web.dart';

enum MqttStatus { disconnected, connecting, connected, reconnecting }

/// Credenciais via --dart-define (nunca commitar senha):
/// flutter run --dart-define=MQTT_HOST=xxx.emqxsl.com \
///   --dart-define=MQTT_USER=usuario --dart-define=MQTT_PASS=senha
class MqttService {
  MqttService._();
  static final MqttService instance = MqttService._();

  static const _host = String.fromEnvironment('MQTT_HOST');
  static const _user = String.fromEnvironment('MQTT_USER');
  static const _pass = String.fromEnvironment('MQTT_PASS');
  static const _wsPort = int.fromEnvironment('MQTT_WS_PORT', defaultValue: 8084);
  // Aceita horta/canteiro1/umidade ... horta/canteiro10/umidade
  static const _topicFilter = 'horta/+/umidade';

  /// Umidade dos 10 canteiros. Começa com valores de demonstração; cada
  /// canteiro é substituído pelo valor real quando o ESP32 publica.
  final ValueNotifier<List<int>> moisture =
      ValueNotifier<List<int>>(const [78, 64, 71, 82, 59, 73, 66, 75, 62, 68]);

  final ValueNotifier<MqttStatus> status =
      ValueNotifier<MqttStatus>(MqttStatus.disconnected);

  /// Canteiros que já receberam leitura real do sensor.
  final ValueNotifier<Set<int>> liveBeds = ValueNotifier<Set<int>>(const {});

  MqttClient? _client;

  Future<void> connect() async {
    if (_host.isEmpty) {
      debugPrint('MQTT: defina --dart-define=MQTT_HOST/USER/PASS. Usando dados de demonstração.');
      return;
    }
    if (status.value == MqttStatus.connected ||
        status.value == MqttStatus.connecting) return;
    status.value = MqttStatus.connecting;

    final id = 'app_horta_${DateTime.now().millisecondsSinceEpoch}';
    final client = createMqttClient(
      host: _host,
      clientId: id,
      tcpPort: 8883,
      wsPort: _wsPort,
    )
      ..keepAlivePeriod = 30
      ..autoReconnect = true
      ..resubscribeOnAutoReconnect = true
      ..logging(on: kDebugMode)
      ..onConnected = (() => status.value = MqttStatus.connected)
      ..onDisconnected = (() => status.value = MqttStatus.disconnected)
      ..onAutoReconnect = (() => status.value = MqttStatus.reconnecting)
      ..onAutoReconnected = (() => status.value = MqttStatus.connected)
      ..connectionMessage = MqttConnectMessage()
          .withClientIdentifier(id)
          .authenticateAs(_user, _pass)
          .startClean();
    _client = client;

    try {
      await client.connect();
    } catch (e) {
      debugPrint('MQTT: falha ao conectar: $e');
      client.disconnect();
      status.value = MqttStatus.disconnected;
      return;
    }

    client.subscribe(_topicFilter, MqttQos.atLeastOnce);
    client.updates?.listen(_onMessages);
  }

  void _onMessages(List<MqttReceivedMessage<MqttMessage?>> msgs) {
    for (final m in msgs) {
      final payload = m.payload as MqttPublishMessage;
      final text =
          MqttPublishPayload.bytesToStringAsString(payload.payload.message);
      final value = double.tryParse(text.trim().replaceAll('%', ''));
      final bed = RegExp(r'canteiro(\d+)').firstMatch(m.topic)?.group(1);
      final index = bed == null ? null : int.parse(bed) - 1;
      if (value == null || index == null || index < 0 || index > 9) continue;

      final next = [...moisture.value]..[index] = value.round().clamp(0, 100);
      moisture.value = next; // nova lista => notifica a UI
      liveBeds.value = {...liveBeds.value, index + 1};
    }
  }

  void disconnect() => _client?.disconnect();
}
