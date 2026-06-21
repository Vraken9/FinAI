import 'dart:io';
import 'package:flutter/material.dart';
import '../../../data/models/parsed_transaction.dart';
import '../ai_text_input_sheet.dart';
import '../ai_voice_input_sheet.dart';
import '../ai_scan_screen.dart';

class AiInputHandler {
  static Future<Map<String, dynamic>?> handleMethod(BuildContext context, String method) async {
    switch (method) {
      case 'text':
        final result = await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          builder: (context) => const AiTextInputSheet(),
        );
        if (result is ParsedTransaction) {
          return {'parsed': result};
        }
        break;

      case 'voice':
        final result = await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          builder: (context) => const AiVoiceInputSheet(),
        );
        if (result is ParsedTransaction) {
          return {'parsed': result};
        }
        break;

      case 'scan':
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AiScanScreen()),
        );
        if (result is Map) {
          return {
            'parsed': result['data'] as ParsedTransaction,
            'image': result['image'] as File?,
          };
        }
        break;
    }
    return null;
  }
}
