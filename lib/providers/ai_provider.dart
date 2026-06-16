import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../data/repositories/ai_repository.dart';
import '../data/models/parsed_transaction.dart';
import '../core/exceptions/app_exception.dart';
import 'asset_provider.dart';

part 'ai_provider.freezed.dart';

@freezed
class AiParseState with _$AiParseState {
  const factory AiParseState.idle() = _Idle;
  const factory AiParseState.loading() = _Loading;
  const factory AiParseState.success(ParsedTransaction data) = _Success;
  const factory AiParseState.error(String message, {required bool isRetryable}) = _Error;
}

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  return AiRepository();
});

final aiParseProvider = StateNotifierProvider<AiParseNotifier, AiParseState>((ref) {
  final repository = ref.watch(aiRepositoryProvider);
  return AiParseNotifier(repository, ref);
});

class AiParseNotifier extends StateNotifier<AiParseState> {
  final AiRepository _repository;
  final Ref _ref;

  AiParseNotifier(this._repository, this._ref) : super(const AiParseState.idle());

  Future<String> _getDefaultAssetId() async {
    try {
      final assetsList = await _ref.read(assetNotifierProvider.future);
      if (assetsList.isEmpty) return '';
      try {
        return assetsList.firstWhere((a) => a.isDefault).id;
      } catch (_) {
        return assetsList.first.id;
      }
    } catch (_) {
      return '';
    }
  }

  Future<void> parseText(String text) async {
    state = const AiParseState.loading();
    try {
      final defaultAssetId = await _getDefaultAssetId();
      final result = await _repository.parseText(text, defaultAssetId);
      state = AiParseState.success(result);
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> parseVoice(File audio) async {
    state = const AiParseState.loading();
    try {
      final defaultAssetId = await _getDefaultAssetId();
      final result = await _repository.parseVoice(audio, defaultAssetId);
      state = AiParseState.success(result);
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> parseImage(File image) async {
    state = const AiParseState.loading();
    try {
      final defaultAssetId = await _getDefaultAssetId();
      final result = await _repository.parseImage(image, defaultAssetId);
      state = AiParseState.success(result);
    } catch (e) {
      _handleError(e);
    }
  }

  void _handleError(Object e) {
    if (e is ApiException) {
      state = AiParseState.error(e.userFriendlyMessage, isRetryable: e.isRetryable);
    } else {
      state = const AiParseState.error('Terjadi kesalahan tidak terduga', isRetryable: true);
    }
  }

  void reset() {
    state = const AiParseState.idle();
  }
}
