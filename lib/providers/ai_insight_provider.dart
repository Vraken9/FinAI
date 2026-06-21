import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/ai_repository.dart';
import 'ai_provider.dart'; // For aiRepositoryProvider

final aiInsightProvider = StateNotifierProvider<AiInsightNotifier, AsyncValue<String?>>((ref) {
  final repo = ref.watch(aiRepositoryProvider);
  return AiInsightNotifier(repo);
});

class AiInsightNotifier extends StateNotifier<AsyncValue<String?>> {
  final AiRepository _repository;
  static const _lastDateKey = 'ai_insight_last_date';
  static const _insightKey = 'ai_insight_text';

  AiInsightNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadInsight();
  }

  Future<void> _loadInsight() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastDate = prefs.getString(_lastDateKey);
      final today = DateTime.now().toIso8601String().split('T')[0];

      if (lastDate == today) {
        // Already generated today
        state = AsyncValue.data(prefs.getString(_insightKey));
        return;
      }

      // Generate new insight
      final prompt = "Berikan SATU insight harian atau saran singkat (maksimal 2 kalimat) tentang keuanganku berdasarkan dataku saat ini. Fokus pada hal paling penting untuk diperbaiki atau diapresiasi hari ini.";
      final insight = await _repository.sendChatMessage(prompt, []);

      // Save it
      await prefs.setString(_lastDateKey, today);
      await prefs.setString(_insightKey, insight);

      state = AsyncValue.data(insight);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refreshInsight() async {
    state = const AsyncValue.loading();
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      
      final prompt = "Berikan SATU insight harian atau saran singkat (maksimal 2 kalimat) tentang keuanganku berdasarkan dataku saat ini. Fokus pada hal paling penting untuk diperbaiki atau diapresiasi hari ini.";
      final insight = await _repository.sendChatMessage(prompt, []);

      await prefs.setString(_lastDateKey, today);
      await prefs.setString(_insightKey, insight);

      state = AsyncValue.data(insight);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
