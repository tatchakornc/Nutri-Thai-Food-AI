import 'package:firebase_auth/firebase_auth.dart';

/// Wraps Firebase Auth with clean error handling
class AuthService {
  final FirebaseAuth _auth;

  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  /// Register with email + password
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await credential.user?.updateDisplayName(displayName.trim());
    return credential;
  }

  /// Login with email + password
  Future<UserCredential> loginWithEmail({
    required String email,
    required String password,
  }) async {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Sign out
  Future<void> signOut() => _auth.signOut();

  /// Send password reset email
  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());
}

/// Convert Firebase auth error codes to Thai user-facing messages
String authErrorToThai(FirebaseAuthException e) {
  switch (e.code) {
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return 'อีเมลหรือรหัสผ่านไม่ถูกต้อง';
    case 'email-already-in-use':
      return 'อีเมลนี้ถูกใช้งานแล้ว';
    case 'weak-password':
      return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
    case 'invalid-email':
      return 'รูปแบบอีเมลไม่ถูกต้อง';
    case 'too-many-requests':
      return 'พยายามเข้าสู่ระบบบ่อยเกินไป กรุณารอสักครู่';
    case 'network-request-failed':
      return 'ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้';
    default:
      return 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง (${e.code})';
  }
}
