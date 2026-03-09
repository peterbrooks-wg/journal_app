import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Possible authentication states.
enum AuthStatus {
  /// User is not signed in.
  unauthenticated,

  /// User is signed in but hasn't completed onboarding.
  onboarding,

  /// User is signed in and has completed onboarding.
  authenticated,
}

/// Manages authentication state for the app.
///
/// Uses SharedPreferences to persist mock auth state.
/// Replace with real Supabase auth in a later phase.
class AuthNotifier extends Notifier<AuthStatus> {
  static const _isSignedInKey = 'is_signed_in';
  static const _onboardingCompleteKey = 'onboarding_complete';

  @override
  AuthStatus build() {
    _loadState();
    return AuthStatus.unauthenticated;
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final isSignedIn = prefs.getBool(_isSignedInKey) ?? false;
    final onboardingComplete =
        prefs.getBool(_onboardingCompleteKey) ?? false;

    if (!isSignedIn) {
      state = AuthStatus.unauthenticated;
    } else if (!onboardingComplete) {
      state = AuthStatus.onboarding;
    } else {
      state = AuthStatus.authenticated;
    }
  }

  /// Mock sign-in. Immediately succeeds.
  Future<void> signIn({required String email}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isSignedInKey, true);
    final onboardingComplete =
        prefs.getBool(_onboardingCompleteKey) ?? false;
    state = onboardingComplete
        ? AuthStatus.authenticated
        : AuthStatus.onboarding;
  }

  /// Mock Apple sign-in. Immediately succeeds.
  Future<void> signInWithApple() async {
    await signIn(email: 'apple@mock.com');
  }

  /// Mock Google sign-in. Immediately succeeds.
  Future<void> signInWithGoogle() async {
    await signIn(email: 'google@mock.com');
  }

  /// Mark onboarding as complete.
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompleteKey, true);
    state = AuthStatus.authenticated;
  }

  /// Sign out and clear persisted state.
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isSignedInKey);
    await prefs.remove(_onboardingCompleteKey);
    state = AuthStatus.unauthenticated;
  }
}

/// Global auth state provider.
final authProvider =
    NotifierProvider<AuthNotifier, AuthStatus>(AuthNotifier.new);
