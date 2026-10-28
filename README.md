# EduGuard

Aplicativo mobile em Flutter para gestão acadêmica de docentes.

O projeto é organizado em MVVM:

- `lib/models` — dados e catálogos
- `lib/views` — interface
- `lib/viewmodels` — estado e operações de apresentação
- `lib/services` — repositórios, autenticação e armazenamento
- `lib/theme` e `lib/widgets` — Design System e componentes reutilizáveis

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

## Autenticação (Firebase)

O cadastro e o login de professores usam **Firebase Authentication**
(e-mail e senha). As senhas são enviadas diretamente ao Firebase e nunca são
armazenadas no dispositivo; a sessão é mantida pelo próprio SDK e restaurada
ao reabrir o app.

O arquivo `lib/firebase_options.dart` versionado é apenas um *placeholder*:
o app compila, mas não inicia até o Firebase ser configurado. Para configurar:

1. Crie um projeto em <https://console.firebase.google.com>.
2. Em **Authentication → Sign-in method**, habilite **E-mail/senha**.
3. Instale as ferramentas e gere a configuração na raiz do repositório:

   ```bash
   npm install -g firebase-tools
   firebase login
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

   O comando registra os apps Android/iOS (`com.eduguard.eduguard`) e
   sobrescreve `lib/firebase_options.dart` com as credenciais do projeto.

Os testes automatizados não dependem do Firebase: usam um `AuthRepository`
falso (`test/support/fake_auth_repository.dart`).

## Dados acadêmicos (versão de demonstração)

Turmas, frequências e avaliações ficam salvas **localmente no dispositivo**
(SharedPreferences), sob um namespace com o UID do professor autenticado
(`eduguard.v1.<uid>.*`). No primeiro acesso, cada professor recebe uma cópia
própria das turmas de exemplo. Encerrar a sessão apenas faz logout: os dados
continuam salvos e voltam no próximo login do mesmo professor.

A camada de dados fica atrás de repositórios (`ClassesRepository`,
`AttendanceRepository`, `GradesRepository`, agrupados em
`AcademicDataScope`), permitindo migrar para o Cloud Firestore sem alterar
telas nem ViewModels.

### Limitações conhecidas

- **Sem sincronização:** os dados acadêmicos existem apenas no aparelho onde
  foram criados; outro dispositivo, a reinstalação do app ou a limpeza dos
  dados do app os perdem.
- **Isolamento apenas lógico:** a separação por UID impede que um professor
  veja os dados de outro *pelo app*, mas os dados não são criptografados.
  Alguém com acesso ao aparelho (root, backup, depuração) consegue lê-los.
  Não armazene informações sensíveis além das necessárias à demonstração.
- **Estudantes de exemplo:** a lista de estudantes é gerada a partir das
  turmas de exemplo; turmas novas ainda não têm cadastro de estudantes.
- **Perfil básico:** o cadastro coleta nome, e-mail e senha; dados
  institucionais (cargo, instituição) ainda não são solicitados.

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
