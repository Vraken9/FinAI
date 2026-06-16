import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Icon(Icons.account_balance_wallet, size: 100, color: AppColors.primaryAccent),
              const SizedBox(height: 32),
              Text('Selamat Datang!', style: AppTextStyles.headline1, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              Text(
                'Ayo mulai atur keuanganmu lebih cerdas dengan FinAI. '
                'Mari siapkan dompet pertama Anda.',
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.push('/onboarding/setup-assets'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Mulai Setup'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
