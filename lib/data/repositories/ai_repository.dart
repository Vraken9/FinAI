import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart' as dio;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import '../../core/exceptions/app_exception.dart';
import '../../core/services/supabase_service.dart';
import '../models/parsed_transaction.dart';

class AiRepository {
  final SupabaseClient _client;
  final dio.Dio _dio;

  AiRepository()
      : _client = SupabaseService().client,
        _dio = dio.Dio(dio.BaseOptions(
          connectTimeout: const Duration(seconds: 45),
          receiveTimeout: const Duration(seconds: 45),
          sendTimeout: const Duration(seconds: 45),
        ));

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
    return _parseMultipart('ai-parse-voice', 'audio', audioFile, defaultAssetId);
  }

  Future<ParsedTransaction> parseImage(File imageFile, String defaultAssetId) async {
    return _parseMultipart('ai-parse-image', 'image', imageFile, defaultAssetId);
  }

  Future<ParsedTransaction> _parseMultipart(String functionName, String fileField, File file, String defaultAssetId) async {
    _checkAuth();

    final baseUrl = dotenv.env['SUPABASE_URL'];
    if (baseUrl == null || baseUrl.isEmpty) {
      throw ApiException(
        'Konfigurasi aplikasi tidak lengkap. Hubungi developer.',
        code: 'CONFIG_ERROR',
      );
    }
    final url = '$baseUrl/functions/v1/$functionName';
    
    try {
      final formData = dio.FormData.fromMap({
        'default_asset_id': defaultAssetId,
        fileField: await dio.MultipartFile.fromFile(file.path),
      });

      final response = await _dio.post(
        url,
        data: formData,
        options: dio.Options(
          headers: {
            'Authorization': 'Bearer $_accessToken',
            'apikey': dotenv.env['SUPABASE_ANON_KEY'] ?? '',
          },
        ),
      );

      final data = response.data;
      if (data['success'] == true && data['data'] != null) {
        return ParsedTransaction.fromJson(data['data']);
      } else {
        throw ApiException(data['error'] ?? 'Gagal memproses request', code: data['code'] ?? 'PARSE_FAILED');
      }
    } on dio.DioException catch (e) {
      debugPrint('DioException in _parseMultipart: Type: ${e.type}, Status: ${e.response?.statusCode}, Data: ${e.response?.data}, Message: ${e.message}');
      
      if (e.type == dio.DioExceptionType.connectionTimeout || 
          e.type == dio.DioExceptionType.receiveTimeout || 
          e.type == dio.DioExceptionType.sendTimeout) {
        throw ApiException('Koneksi timeout, periksa internet kamu dan coba lagi', code: 'NETWORK_TIMEOUT');
      } else if (e.type == dio.DioExceptionType.connectionError) {
        throw ApiException('Tidak ada koneksi internet', code: 'NETWORK_ERROR');
      } else if (e.type == dio.DioExceptionType.badResponse) {
        final responseData = e.response?.data;
      if (responseData is Map && responseData['error'] != null) {
        throw ApiException(
          responseData['error'] as String,
          code: responseData['code'] as String? ?? 'PARSE_FAILED',
        );
      } else if (responseData is String) {
        try {
          final decoded = jsonDecode(responseData);
          if (decoded is Map && decoded['error'] != null) {
            throw ApiException(
              decoded['error'] as String,
              code: decoded['code'] as String? ?? 'PARSE_FAILED',
            );
          }
        } catch (_) {}
      }
      } // <-- missing brace for badResponse block
      
      throw ApiException('Layanan AI sedang sibuk. Coba lagi.', code: 'UNKNOWN');
    } catch (e, stackTrace) {
      debugPrint('Error in _parseMultipart: $e\n$stackTrace');
      if (e is ApiException) rethrow;
      throw ApiException('Terjadi kesalahan tidak terduga', code: 'UNKNOWN');
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
