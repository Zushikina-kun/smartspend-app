import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_auth/local_auth.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _googleSignIn = GoogleSignIn();
  static final _localAuth = LocalAuthentication();

  // ── EMAIL / PASSWORD ──────────────────────────────────────

  static Future<User?> login(String email, String password) async {
    final res = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return res.user;
  }

  static Future<User?> register(String email, String password) async {
    final res = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return res.user;
  }

  static Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ── GOOGLE SIGN-IN ────────────────────────────────────────

  /// Sign in with Google. If the user already has an email/password account
  /// with the same email, this links the Google credential to it.
  static Future<User?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // user cancelled

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Try direct sign-in first
      try {
        final res = await _auth.signInWithCredential(credential);
        return res.user;
      } on FirebaseAuthException catch (e) {
        // If account exists with a different credential (e.g. email/password),
        // signal the caller to prompt for the password so we can link accounts.
        // Note: fetchSignInMethodsForEmail() is deprecated — we no longer call it.
        // Instead we rely on the error code and throw a typed exception so the
        // login screen can show the appropriate message.
        if (e.code == 'account-exists-with-different-credential') {
          final email = e.email;
          if (email == null) rethrow;
          throw _LinkAccountException(email: email, credential: credential);
        }
        rethrow;
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Link Google credential to an existing email/password account
  static Future<User?> linkGoogleToExisting(
      String password, OAuthCredential googleCredential, String email) async {
    final res = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    await res.user?.linkWithCredential(googleCredential);
    return res.user;
  }

  /// Link Google to the currently signed-in account (from profile settings)
  static Future<User?> linkGoogleToCurrentUser() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final res = await _auth.currentUser?.linkWithCredential(credential);
    return res?.user;
  }

  /// Check if current user has Google linked
  static bool get isGoogleLinked {
    final user = _auth.currentUser;
    if (user == null) return false;
    return user.providerData.any((p) => p.providerId == 'google.com');
  }

  // ── BIOMETRIC AUTH ────────────────────────────────────────

  /// Returns true if device supports biometrics and has enrolled biometrics
  static Future<bool> get isBiometricAvailable async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      if (!canCheck || !isSupported) return false;
      final biometrics = await _localAuth.getAvailableBiometrics();
      return biometrics.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Authenticate with biometrics. Returns true on success.
  static Future<bool> authenticateWithBiometrics() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access Smart Spend',
        options: const AuthenticationOptions(
          biometricOnly: false, // allow PIN fallback
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  static User? get currentUser => _auth.currentUser;
}

/// Thrown when Google sign-in finds an existing email/password account
class _LinkAccountException implements Exception {
  final String email;
  final OAuthCredential credential;
  _LinkAccountException({required this.email, required this.credential});
}
