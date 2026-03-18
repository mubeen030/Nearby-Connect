import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService({FirebaseAuth? firebaseAuth}) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<UserCredential> signUp({required String email, required String password}) {
    return _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signIn({required String email, required String password}) {
    return _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() => _firebaseAuth.signOut();

  Future<void> sendPasswordResetEmail(String email) => _firebaseAuth.sendPasswordResetEmail(email: email);
}
