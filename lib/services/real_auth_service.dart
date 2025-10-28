import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RealAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signIn(String email, String password) async {
    try {
      if (password.length < 6) {
        throw FirebaseAuthException(
          code: 'weak-password',
          message: 'Le mot de passe doit contenir au moins 6 caractères',
        );
      }

      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      await _ensureUserPool(result.user!);
      return result.user;
    } on FirebaseAuthException catch (e) {
      rethrow;
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  Future<User?> signUp(String email, String password) async {
    try {
      if (password.length < 6) {
        throw FirebaseAuthException(
          code: 'weak-password',
          message: 'Le mot de passe doit contenir au moins 6 caractères',
        );
      }

      if (!email.contains('@')) {
        throw FirebaseAuthException(
          code: 'invalid-email',
          message: 'Email invalide',
        );
      }

      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      await _createUserProfile(result.user!, email);
      await _createUserPool(result.user!);
      
      return result.user;
    } on FirebaseAuthException catch (e) {
      rethrow;
    } catch (e) {
      throw Exception('Erreur d\'inscription: $e');
    }
  }

  Future<void> _createUserProfile(User user, String email) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erreur création profil: $e');
    }
  }

  Future<void> _createUserPool(User user) async {
    try {
      final poolId = 'pool_${user.uid}';
      await _firestore.collection('pools').doc(poolId).set({
        'userId': user.uid,
        'name': 'Ma Piscine',
        'createdAt': FieldValue.serverTimestamp(),
        'temperature': 25.0,
        'ph': 7.2,
        'water_level': 85.0,
        'pump_status': true,
        'last_update': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erreur création piscine: $e');
    }
  }

  Future<void> _ensureUserPool(User user) async {
    try {
      final poolId = 'pool_${user.uid}';
      final poolDoc = await _firestore.collection('pools').doc(poolId).get();
      if (!poolDoc.exists) {
        await _createUserPool(user);
      }
    } catch (e) {
      print('Erreur vérification piscine: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Stream<User?> get user {
    return _auth.authStateChanges();
  }

  String getCurrentUserPoolId() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');
    return 'pool_${user.uid}';
  }

  User? get currentUser {
    return _auth.currentUser;
  }
}