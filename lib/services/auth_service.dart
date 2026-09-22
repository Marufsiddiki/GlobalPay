import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth;
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  Future<UserCredential> signIn(String email, String password) => _auth.signInWithEmailAndPassword(email: email, password: password);
  Future<UserCredential> signUp(String email, String password) => _auth.createUserWithEmailAndPassword(email: email, password: password);
  Future<void> resetPassword(String email) => _auth.sendPasswordResetEmail(email: email);
  Future<void> signOut() => _auth.signOut();
}