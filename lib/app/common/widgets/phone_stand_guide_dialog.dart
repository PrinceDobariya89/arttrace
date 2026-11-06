import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/storage/storage_service.dart';
import '../../theme/app_colors.dart';

class PhoneStandGuideDialog extends StatefulWidget {
  final VoidCallback onProceed;

  const PhoneStandGuideDialog({super.key, required this.onProceed});

  static Future<void> showIfNeeded(BuildContext context, {required VoidCallback onProceed}) async {
    final storage = Get.find<StorageService>();
    if (storage.showStandGuide.value) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => PhoneStandGuideDialog(onProceed: onProceed),
      );
    } else {
      onProceed();
    }
  }

  @override
  State<PhoneStandGuideDialog> createState() => _PhoneStandGuideDialogState();
}

class _PhoneStandGuideDialogState extends State<PhoneStandGuideDialog> {
  bool _dontShowAgain = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header icon
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.stay_current_portrait_rounded,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'How to Trace Like a Pro',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'For the best tracing stability and precision:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondaryLight),
            ),
            const SizedBox(height: 20),

            _buildTipRow(
              Icons.wine_bar_rounded,
              'Use a Glass or Stand',
              'Place your phone across a clear glass cup, mug, or phone tripod so it stays still.',
            ),
            const SizedBox(height: 14),
            _buildTipRow(
              Icons.height_rounded,
              '20 - 30 cm Distance',
              'Position your phone 20–30 cm directly above your blank sheet of sketch paper.',
            ),
            const SizedBox(height: 14),
            _buildTipRow(
              Icons.lock_outline_rounded,
              'Lock the Image',
              'Use the Lock button on the screen so your hand won\'t accidentally move the sketch.',
            ),
            const SizedBox(height: 20),

            // Don't show again checkbox
            Row(
              children: [
                Checkbox(
                  value: _dontShowAgain,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() => _dontShowAgain = val ?? false);
                  },
                ),
                const Text(
                  'Don\'t show this again',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Proceed button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_dontShowAgain) {
                    Get.find<StorageService>().setShowStandGuide(false);
                  }
                  Navigator.of(context).pop();
                  widget.onProceed();
                },
                child: const Text('Start Tracing Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipRow(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight, height: 1.3),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

