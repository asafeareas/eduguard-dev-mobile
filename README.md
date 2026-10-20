# EduGuard

Aplicativo mobile em Flutter para gestão acadêmica de docentes.

Esta etapa contém apenas o esqueleto inicial do projeto, organizado em MVVM:

- `lib/models` — dados e catálogos
- `lib/views` — interface
- `lib/viewmodels` — estado e operações de apresentação

## Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.13 ou superior
- Dart (incluído no Flutter)
- Android Studio / Android SDK para executar no Android
- Xcode (somente em macOS) para executar no iOS

Verifique a instalação:

```bash
flutter doctor
```

## Instalar dependências

Na raiz do repositório:

```bash
flutter pub get
```

## Executar o aplicativo

Liste os dispositivos disponíveis:

```bash
flutter devices
```

Execute em um emulador, simulador ou aparelho conectado:

```bash
flutter run
```

Para escolher a plataforma:

```bash
flutter run -d android
flutter run -d ios
```

## Análise estática

```bash
flutter analyze
```

## Testes

```bash
flutter test
```
