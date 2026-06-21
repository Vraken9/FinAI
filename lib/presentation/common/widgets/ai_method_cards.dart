import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class AiMethodCards extends StatelessWidget {
  final Function(String method) onMethodSelected;

  const AiMethodCards({super.key, required this.onMethodSelected});

  Widget _buildMethodCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: iconColor.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 12),
            Text(title, style: AppTextStyles.body.copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.primaryAccent),
              const SizedBox(width: 8),
              Text('Pilih Metode AI', style: AppTextStyles.headline1.copyWith(color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 8),
          Text('Catat transaksi keuangan Anda secara otomatis.', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildMethodCard(
                  icon: Icons.text_fields,
                  iconColor: Colors.purple,
                  title: 'Ketik',
                  subtitle: 'Makan 25rb',
                  onTap: () => onMethodSelected('text'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMethodCard(
                  icon: Icons.mic,
                  iconColor: Colors.orange,
                  title: 'Suara',
                  subtitle: 'Rekam',
                  onTap: () => onMethodSelected('voice'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMethodCard(
                  icon: Icons.camera_alt,
                  iconColor: Colors.green,
                  title: 'Scan',
                  subtitle: 'Struk',
                  onTap: () => onMethodSelected('scan'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16), // Bottom padding safe area
        ],
      ),
    );
  }
}
