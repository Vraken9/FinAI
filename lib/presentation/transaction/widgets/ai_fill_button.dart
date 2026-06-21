import 'dart:io';
import 'package:flutter/material.dart';
import '../../../data/models/parsed_transaction.dart';
import '../../common/widgets/ai_method_cards.dart';
import '../../ai_input/utils/ai_input_handler.dart';

class AiFillButton extends StatelessWidget {
  final Function(ParsedTransaction data, [File? image]) onAiParsed;

  const AiFillButton({super.key, required this.onAiParsed});

  Future<void> _handleMethodSelection(BuildContext context, String method) async {
    Navigator.pop(context); // Close the bottom sheet first
    
    final result = await AiInputHandler.handleMethod(context, method);
    
    if (result != null && result['parsed'] != null) {
      onAiParsed(result['parsed'] as ParsedTransaction, result['image'] as File?);
    }
  }

  void _showAiOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return AiMethodCards(
          onMethodSelected: (method) => _handleMethodSelection(context, method),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'ai_fab', // prevent hero tag collision if there's another FAB
      onPressed: () => _showAiOptions(context),
      backgroundColor: Colors.purple, // AI color
      child: const Icon(Icons.auto_awesome, color: Colors.white),
    );
  }
}
