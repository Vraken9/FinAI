import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/auth_repository.dart';
import '../data/models/user_profile.dart';

part 'auth_provider.g.dart';

enum RegisterResult { loggedIn, needsEmailConfirmation }

class AuthState {
  final bool isLoadingAuth;
  final bool isLoggedIn;
  final bool isOnboarded;
  final bool isPinLocked;
  final UserProfile? profile;

  AuthState({
    this.isLoadingAuth = true,
    this.isLoggedIn = false,
    this.isOnboarded = false,
    this.isPinLocked = false,
    this.profile,
  });

  AuthState copyWith({
    bool? isLoadingAuth,
    bool? isLoggedIn,
    bool? isOnboarded,
    bool? isPinLocked,
    UserProfile? profile,
  }) {
    return AuthState(
      isLoadingAuth: isLoadingAuth ?? this.isLoadingAuth,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      isPinLocked: isPinLocked ?? this.isPinLocked,
      profile: profile ?? this.profile,
    );
  }
}

@riverpod
class AuthNotifier extends _$AuthNotifier {
  late AuthRepository _repository;

  @override
  AuthState build() {
    _repository = AuthRepository();
    final user = _repository.getCurrentUser();
    
    if (user == null) {
      return AuthState(isLoadingAuth: false, isLoggedIn: false);
    } else {
      _fetchProfile(); // fire-and-forget AMAN karena ada 'await' di dalamnya
      return AuthState(isLoadingAuth: false, isLoggedIn: true);
    }
  }

  Future<void> _fetchProfile() async {
    final profile = await _repository.getProfile();
    state = state.copyWith(
      profile: profile,
      isOnboarded: profile?.onboardingCompleted ?? false,
      isPinLocked: profile?.pinHash != null,
    );
  }

  Future<void> login(String email, String password) async {
    await _repository.signInWithEmail(email, password);
    _fetchProfile();
    state = state.copyWith(isLoggedIn: true);
  }

  Future<RegisterResult> register(String email, String password, String fullName) async {
    final response = await _repository.signUpWithEmail(email, password, fullName);
    
    if (response.session != null) {
      _fetchProfile();
      state = state.copyWith(isLoggedIn: true, isLoadingAuth: false);
      return RegisterResult.loggedIn;
    } else {
      return RegisterResult.needsEmailConfirmation;
    }
  }

  Future<void> loginWithGoogle() async {
    await _repository.signInWithGoogle();
  }

  Future<void> logout() async {
    await _repository.signOut();
    state = AuthState();
  }

  Future<void> completeOnboarding() async {
    await _repository.updateProfile({'onboarding_completed': true});
    state = state.copyWith(isOnboarded: true);
  }

  void unlockPin() {
    state = state.copyWith(isPinLocked: false);
  }
}
