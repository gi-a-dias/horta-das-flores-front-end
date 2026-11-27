# Horta das Flores — Flutter

O aplicativo Flutter está em `lib/main.dart` e não depende de pacotes de UI
externos.

## Executar

Com Flutter 3.19 ou superior instalado:

```bash
flutter create --platforms=android,ios,web .
flutter pub get
flutter run
```

O primeiro comando gera somente os runners nativos que não fazem parte deste
workspace. O código da aplicação, o tema e as três telas permanecem em
`lib/main.dart`.

## Estrutura

- `HortaDasFloresApp`: tema Material 3 e configuração global.
- `HortaNavigator`: fluxo entre login, jardim e irrigação.
- `LoginScreen`: autenticação e acesso como convidado.
- `GardenScreen`: mapa virtual, filtros e analytics dos sensores.
- `IrrigationScreen`: leitura ESP32 e controle local de rega.
- `CustomPainter`: padrão botânico, jardim isométrico, gráfico e planta.
