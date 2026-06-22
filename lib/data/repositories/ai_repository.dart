import 'dart:io';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../core/exceptions/app_exception.dart';
import '../../core/services/supabase_service.dart';
import '../models/parsed_transaction.dart';

class AiRepository {
  final SupabaseClient _client;

  AiRepository()
      : _client = SupabaseService().client;

  String? get _accessToken {
    return _client.auth.currentSession?.accessToken;
  }

  void _checkAuth() {
    if (_accessToken == null) {
      throw ApiException('Sesi habis, silakan login kembali', code: 'UNAUTHORIZED');
    }
  }

  Future<ParsedTransaction> parseText(String text, String defaultAssetId) async {
    _checkAuth();

    try {
      final response = await _client.functions.invoke(
        'ai-parse-text',
        body: {
          'text': text,
          'default_asset_id': defaultAssetId,
        },
      );

      final data = response.data;
      if (data['success'] == true && data['data'] != null) {
        return ParsedTransaction.fromJson(data['data']);
      } else {
        throw ApiException(data['error'] ?? 'Gagal memproses teks', code: data['code'] ?? 'PARSE_FAILED');
      }
    } on FunctionException catch (e) {
      debugPrint('FunctionException in parseText: Status: ${e.status}, Reason: ${e.reasonPhrase}, Details: ${e.details}');
      final message = e.reasonPhrase ?? 'Terjadi kesalahan pada layanan AI';
      throw ApiException(message, code: 'EXTERNAL_API_ERROR');
    } catch (e, stackTrace) {
      debugPrint('Error in parseText: $e\n$stackTrace');
      if (e is ApiException) rethrow;
      throw ApiException('Terjadi kesalahan tidak terduga', code: 'UNKNOWN');
    }
  }

  Future<ParsedTransaction> parseVoice(File audioFile, String defaultAssetId) async {
    return _parseWithInvoke('ai-parse-voice', 'audio_base64', audioFile, defaultAssetId);
  }

  Future<ParsedTransaction> parseImage(File imageFile, String defaultAssetId) async {
    return _parseWithInvoke('ai-parse-image', 'image_base64', imageFile, defaultAssetId);
  }

  Future<ParsedTransaction> _parseWithInvoke(String functionName, String fileField, File file, String defaultAssetId) async {
    _checkAuth();

    try {
      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);

      final response = await _client.functions.invoke(
        functionName,
        body: {
          'default_asset_id': defaultAssetId,
          fileField: base64String,
          'mime_type': _getMimeType(file.path, fileField),
        },
      );

      final data = response.data;
      if (data != null && data['success'] == true && data['data'] != null) {
        return ParsedTransaction.fromJson(data['data']);
      } else {
        final err = data?['error'] ?? 'Gagal memproses request';
        final code = data?['code'] ?? 'PARSE_FAILED';
        throw ApiException(err.toString(), code: code.toString());
      }
    } on FunctionException catch (e) {
      debugPrint('FunctionException in _parseWithInvoke: Status: ${e.status}, Details: ${e.details}');
      
      // Coba tangkap error detail dari JSON
      try {
        if (e.details != null && e.details is Map) {
          final errorMsg = e.details['error'];
          final code = e.details['code'];
          if (errorMsg != null) {
            throw ApiException(errorMsg.toString(), code: code?.toString() ?? 'EXTERNAL_API_ERROR');
          }
        }
      } catch (_) {}
      
      throw ApiException('Layanan AI gagal merespon dengan benar. Coba lagi.', code: 'EXTERNAL_API_ERROR');
    } catch (e, stackTrace) {
      debugPrint('Error in _parseWithInvoke: $e\n$stackTrace');
      if (e is ApiException) rethrow;
      throw ApiException('Terjadi kesalahan tidak terduga', code: 'UNKNOWN');
    }
  }

  String _getMimeType(String path, String fileField) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'm4a':
        return 'audio/m4a';
      case 'mp3':
        return 'audio/mpeg';
      case 'wav':
        return 'audio/wav';
      case 'webm':
        return 'audio/webm';
      default:
        return fileField == 'image_base64' ? 'image/jpeg' : 'audio/webm'; // fallback
    }
  }


  Future<String> sendChatMessage(String message, List<Map<String, dynamic>> history) async {
    _checkAuth();

    try {
      final response = await _client.functions.invoke(
        'ai-chat',
        body: {
          'message': message,
          'history': history,
        },
      );

      final data = response.data;
      if (data['success'] == true) {
        return data['reply'] ?? '';
      } else {
        throw ApiException(data['error'] ?? 'Gagal memproses chat', code: data['code'] ?? 'CHAT_FAILED');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Terjadi kesalahan koneksi', code: 'EXTERNAL_API_ERROR');
    }
  }
}
