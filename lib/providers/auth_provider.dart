import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../data/repositories/auth_repository.dart';
import '../data/models/user_profile.dart';
import '../../core/services/supabase_service.dart';

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
    
    // Listen to deep links / background auth state changes
    SupabaseService().client.auth.onAuthStateChange.listen((data) {
      final supa.AuthChangeEvent event = data.event;
      final supa.Session? session = data.session;
      
      if (event == supa.AuthChangeEvent.signedIn && session != null) {
        if (!state.isLoggedIn) {
          _fetchProfile();
          state = state.copyWith(isLoggedIn: true, isLoadingAuth: false);
        }
      } else if (event == supa.AuthChangeEvent.signedOut) {
        state = AuthState(isLoadingAuth: false);
      }
    });

    final user = _repository.getCurrentUser();
    
    if (user == null) {
      return AuthState(isLoadingAuth: false, isLoggedIn: false);
    } else {
      _fetchProfileInitial();
      return AuthState(isLoadingAuth: true, isLoggedIn: true);
    }
  }

  Future<void> _fetchProfileInitial() async {
    final profile = await _repository.getProfile();
    state = state.copyWith(
      profile: profile,
      isOnboarded: profile?.onboardingCompleted ?? false,
      isPinLocked: profile?.pinHash != null,
      isLoadingAuth: false,
    );
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

  Future<void> verifyOtp(String email, String token) async {
    final response = await _repository.verifyEmailOtp(email, token);
    if (response.session != null) {
      _fetchProfile();
      state = state.copyWith(isLoggedIn: true, isLoadingAuth: false);
    }
  }

  Future<void> loginWithGoogle() async {
    await _repository.signInWithGoogle();
  }

  Future<void> logout() async {
    await _repository.signOut();
    state = AuthState(isLoadingAuth: false);
  }

  Future<void> completeOnboarding() async {
    await _repository.updateProfile({'onboarding_completed': true});
    state = state.copyWith(isOnboarded: true);
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    await _repository.updateProfile(data);
    await _fetchProfile();
  }

  void unlockPin() {
    state = state.copyWith(isPinLocked: false);
  }
}
