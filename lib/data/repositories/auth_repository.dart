import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/exceptions/app_exception.dart';
import '../../core/services/supabase_service.dart';
import '../models/user_profile.dart';

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository() : _client = SupabaseService().client;

  Future<AuthResponse> signInWithEmail(String email, String password) async {
    try {
      return await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('rate limit')) {
        throw ApiException('Terlalu banyak percobaan, tunggu beberapa menit', code: 'RATE_LIMITED');
      }
      if (e.message.contains('Invalid login credentials')) {
        throw ApiException('Email atau password salah', code: 'INVALID_CREDENTIALS');
      }
      throw ApiException(e.message, code: 'AUTH_ERROR');
    } catch (e) {
      throw NetworkException('Tidak ada koneksi jaringan, periksa koneksi Anda.');
    }
  }

  Future<AuthResponse> signUpWithEmail(String email, String password, String fullName) async {
    try {
      return await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('rate limit')) {
        throw ApiException('Terlalu banyak percobaan, tunggu beberapa menit', code: 'RATE_LIMITED');
      }
      if (e.message.contains('already registered') || e.message.contains('User already registered')) {
        throw ApiException('Email sudah terdaftar', code: 'EMAIL_EXISTS');
      }
      if (e.message.toLowerCase().contains('password should be at least')) {
        throw ApiException('Password minimal 6 karakter', code: 'AUTH_ERROR');
      }
      if (e.message.toLowerCase().contains('invalid email') || e.message.toLowerCase().contains('invalid format')) {
        throw ApiException('Format email tidak valid', code: 'AUTH_ERROR');
      }
      throw ApiException(e.message, code: 'AUTH_ERROR');
    } catch (e) {
      throw NetworkException('Tidak ada koneksi jaringan, periksa koneksi Anda.');
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      return await _client.auth.signInWithOAuth(OAuthProvider.google);
    } catch (e) {
      throw ApiException('Gagal login dengan Google', code: 'OAUTH_ERROR');
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  Future<UserProfile?> getProfile() async {
    final user = getCurrentUser();
    if (user == null) return null;

    try {
      final response = await _client
          .from('user_profiles')
          .select()
          .eq('id', user.id)
          .single();
      return UserProfile.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    final user = getCurrentUser();
    if (user == null) throw ApiException('User not logged in', code: 'UNAUTHORIZED');

    try {
      await _client
          .from('user_profiles')
          .update(updates)
          .eq('id', user.id);
    } catch (e) {
      throw ApiException('Gagal memperbarui profil', code: 'DATABASE_ERROR');
    }
  }
}
