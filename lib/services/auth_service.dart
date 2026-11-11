import 'package:firebase_auth/firebase_auth.dart';

/// Login com e-mail e senha (Firebase Authentication).
class AuthService {
  AuthService([FirebaseAuth? auth]) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Stream<User?> userChanges() => _auth.userChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email.trim(), password: password);

  /// Cria a conta (usado no primeiro acesso da nutricionista) e envia verificação.
  Future<void> register(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
    await cred.user?.sendEmailVerification();
  }

  Future<void> sendVerificationEmail() async => _auth.currentUser?.sendEmailVerification();

  /// Recarrega o usuário e o token (após confirmar o e-mail).
  Future<void> refresh() async {
    await _auth.currentUser?.reload();
    await _auth.currentUser?.getIdToken(true);
  }

  Future<void> sendPasswordReset(String email) => _auth.sendPasswordResetEmail(email: email.trim());

  Future<void> changePassword(String current, String next) async {
    final user = _auth.currentUser!;
    final cred = EmailAuthProvider.credential(email: user.email!, password: current);
    await user.reauthenticateWithCredential(cred);
    await user.updatePassword(next);
  }

  Future<void> signOut() => _auth.signOut();

  /// Mensagem amigável para erros do Firebase Auth.
  static String describe(Object error) {
    if (error is FirebaseAuthException) {
      return switch (error.code) {
        'invalid-email' => 'E-mail inválido.',
        'user-disabled' => 'Esta conta foi desativada.',
        'user-not-found' || 'wrong-password' || 'invalid-credential' => 'E-mail ou senha incorretos.',
        'email-already-in-use' => 'Já existe uma conta com este e-mail.',
        'weak-password' => 'Senha fraca: use pelo menos 6 caracteres.',
        'too-many-requests' => 'Muitas tentativas. Aguarde alguns minutos.',
        'network-request-failed' => 'Sem conexão com a internet.',
        'requires-recent-login' => 'Entre novamente para continuar.',
        _ => 'Erro: ${error.message ?? error.code}',
      };
    }
    return 'Algo deu errado. Tente novamente.';
  }
}
