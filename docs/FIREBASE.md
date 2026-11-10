# Firebase (fase 2)

## Serviços

| Serviço | Uso |
|---------|-----|
| Authentication | Login por e-mail/senha; paciente entra por convite |
| Cloud Firestore | Cardápios, receitas, diário, chat, base TACO |
| Cloud Storage | Fotos do chat e das receitas |
| Cloud Messaging (FCM) | Notificação de nova mensagem |
| Cloud Functions | Disparo das notificações e criação de contas por convite |

## Configuração

```bash
dart pub global activate flutterfire_cli
firebase login
flutterfire configure --project=<id-do-projeto>
flutter pub add firebase_core firebase_auth cloud_firestore firebase_storage firebase_messaging image_picker
```

`flutterfire configure` gera `lib/firebase_options.dart`, `google-services.json` e
`GoogleService-Info.plist`. Esses arquivos estão no `.gitignore`.

## Regras de segurança (rascunho)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{db}/documents {
    function signedIn() { return request.auth != null; }
    function isNutri() {
      return signedIn() &&
        get(/databases/$(db)/documents/users/$(request.auth.uid)).data.role == 'nutritionist';
    }
    function isOwner(uid) { return signedIn() && request.auth.uid == uid; }

    match /users/{uid} { allow read: if isOwner(uid) || isNutri(); allow write: if isNutri(); }
    match /foods/{id}  { allow read: if signedIn(); allow write: if false; }
    match /recipes/{id} { allow read: if signedIn(); allow write: if isNutri(); }

    match /patients/{uid}/mealPlans/{id} { allow read: if isOwner(uid) || isNutri(); allow write: if isNutri(); }
    match /patients/{uid}/diary/{id}     { allow read, write: if isOwner(uid) || isNutri(); }
    match /chats/{uid}/messages/{id}     { allow read, create: if isOwner(uid) || isNutri(); }
  }
}
```

## Notificações

1. O app salva o token FCM do dispositivo em `users/{uid}.fcmTokens`.
2. Uma Cloud Function `onCreate` em `chats/{patientUid}/messages/{id}` envia o push
   para o destinatário (paciente ou nutricionista).
3. Ao tocar na notificação o app abre a aba Chat.

## LGPD

Dados de alimentação e saúde são **dados pessoais sensíveis**. Antes de ir para produção:

- termo de consentimento no primeiro acesso;
- política de privacidade;
- opção de excluir conta e dados;
- acesso restrito pelas regras acima.
