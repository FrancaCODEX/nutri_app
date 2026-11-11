import 'package:firebase_core/firebase_core.dart';

/// Configuração do projeto Firebase (extraída de android/app/google-services.json).
///
/// Estes valores identificam o projeto e não são segredos: o acesso aos dados
/// é controlado pelas regras em firebase/firestore.rules.
class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAB4mpfc8CFZ4w4cqeljqbjwoRY-y13qsE',
    appId: '1:993283495539:android:85371347fbfa66c1ba7c06',
    messagingSenderId: '993283495539',
    projectId: 'nutri-app-42226',
    storageBucket: 'nutri-app-42226.firebasestorage.app',
  );

  static FirebaseOptions get currentPlatform => android;
}
