import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ai_message.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(Supabase.instance.client);
});

class ChatRepository {
  final SupabaseClient _supabase;
  final dio.Dio _dio;

  ChatRepository(this._supabase)
      : _dio = dio.Dio(dio.BaseOptions(
          connectTimeout: const Duration(seconds: 45),
          receiveTimeout: const Duration(seconds: 45),
          sendTimeout: const Duration(seconds: 45),
        ));

  Future<List<AiMessage>> getConversationHistory() async {
    final response = await _supabase
        .from('ai_messages')
        .select()
        .order('created_at', ascending: true)
        .limit(50); // Get last 50 messages to prevent overload
    
    return (response as List).map((json) => AiMessage.fromJson(json)).toList();
  }

  Future<String> sendMessage(String message, List<Map<String, dynamic>> history) async {
    final response = await _supabase.functions.invoke(
      'ai-chat',
      body: {
        'message': message,
        'history': history,
      },
    );

    if (response.status == 200) {
      final data = response.data;
      if (data['success'] == true) {
        return data['response'] as String;
      } else {
        throw Exception(data['error'] ?? 'Terjadi kesalahan pada AI Chat');
      }
    } else {
      throw Exception('Gagal menghubungi AI Chat (Status: ${response.status})');
    }
  }
  Future<String> transcribeVoice(File audioFile) async {
    final baseUrl = dotenv.env['SUPABASE_URL'];
    final url = '$baseUrl/functions/v1/ai-chat';
    final token = _supabase.auth.currentSession?.accessToken;
    
    if (token == null) throw Exception('Sesi habis, silakan login kembali');

    try {
      final formData = dio.FormData.fromMap({
        'mode': 'transcribe',
        'audio': await dio.MultipartFile.fromFile(audioFile.path),
      });

      final response = await _dio.post(
        url,
        data: formData,
        options: dio.Options(
          headers: {
            'Authorization': 'Bearer $token',
            'apikey': dotenv.env['SUPABASE_ANON_KEY'] ?? '',
          },
        ),
      );

      final data = response.data;
      if (data['success'] == true && data['transcription'] != null) {
        return data['transcription'] as String;
      } else {
        throw Exception(data['error'] ?? 'Gagal memproses suara');
      }
    } on dio.DioException catch (e) {
      throw Exception('Gagal menghubungi server untuk STT: ${e.message}');
    }
  }
}
