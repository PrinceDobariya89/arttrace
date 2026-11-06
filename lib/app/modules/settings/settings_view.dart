import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/utils/constants.dart';
import '../../common/widgets/premium_badge.dart';
import '../../theme/app_colors.dart';
import 'settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pro Membership Card
            _buildProCard(context),
            const SizedBox(height: 24),

            // Tracing Preferences
            _buildSectionHeader('Tracing Preferences'),
            const SizedBox(height: 10),
            _buildCardGroup(context, [
              // Default Opacity Slider
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.opacity_rounded, size: 20, color: AppColors.primary),
                        const SizedBox(width: 12),
                        const Text(
                          'Default Tracing Opacity',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        const Spacer(),
                        Obx(
                          () => Text(
                            '${(controller.defaultOpacity.value * 100).toInt()}%',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => Slider(
                        value: controller.defaultOpacity.value,
                        min: 0.1,
                        max: 1.0,
                        onChanged: controller.setDefaultOpacity,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Haptic Feedback Switch
              Obx(
                () => SwitchListTile(
                  secondary: const Icon(Icons.vibration_rounded, color: AppColors.primary, size: 20),
                  title: const Text('Haptic Vibration', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Gentle vibrations when locking and tapping tools', style: TextStyle(fontSize: 12)),
                  value: controller.hapticEnabled.value,
                  onChanged: controller.toggleHaptic,
                ),
              ),
              const Divider(height: 1),
              // Reset Stand Setup Guide
              ListTile(
                leading: const Icon(Icons.refresh_rounded, color: AppColors.primary, size: 20),
                title: const Text('Reset Phone Stand Guide', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: const Text('Show the cup/stand instructions on next trace', style: TextStyle(fontSize: 12)),
                onTap: controller.resetStandGuide,
              ),
            ]),
            const SizedBox(height: 24),

            // Theme & Display
            _buildSectionHeader('Appearance'),
            const SizedBox(height: 10),
            _buildCardGroup(context, [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('App Theme Mode', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 12),
                    Obx(
                      () => Row(
                        children: [
                          _buildThemeOption(context, 'system', 'System', Icons.brightness_auto_rounded),
                          const SizedBox(width: 10),
                          _buildThemeOption(context, 'light', 'Light', Icons.light_mode_rounded),
                          const SizedBox(width: 10),
                          _buildThemeOption(context, 'dark', 'Dark', Icons.dark_mode_rounded),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 24),

            // In-App Purchases & Billing
            _buildSectionHeader('Membership & Billing'),
            const SizedBox(height: 10),
            _buildCardGroup(context, [
              ListTile(
                leading: const Icon(Icons.workspace_premium_rounded, color: Colors.orange, size: 22),
                title: const Text('Unlock ArtTrace PRO', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                subtitle: const Text('Get all anime sketches & remove all ads', style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: controller.openPremium,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.restore_rounded, color: AppColors.secondary, size: 22),
                title: const Text('Restore Purchases', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: const Text('Recover previously purchased subscriptions', style: TextStyle(fontSize: 12)),
                onTap: controller.restorePurchases,
              ),
            ]),
            const SizedBox(height: 24),

            // Support & About
            _buildSectionHeader('Support & Legal'),
            const SizedBox(height: 10),
            _buildCardGroup(context, [
              ListTile(
                leading: const Icon(Icons.star_outline_rounded, color: AppColors.primary, size: 22),
                title: const Text('Rate ArtTrace', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                onTap: controller.rateApp,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.share_outlined, color: AppColors.primary, size: 22),
                title: const Text('Share App with Friends', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                onTap: controller.shareApp,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.primary, size: 22),
                title: const Text('Privacy Policy', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: controller.openPrivacyPolicy,
              ),
            ]),

            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  Text(
                    '${AppConstants.appName} v${AppConstants.appVersion}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.textMutedDark
                          : AppColors.textMutedLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Made with Flutter & Computer Vision Overlay',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.textMutedDark
                          : AppColors.textMutedLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProCard(BuildContext context) {
    return Obx(() {
      final isPro = controller.storageService.isPremium.value;
      if (isPro) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.darkCardGradient,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.amber, width: 1.2),
          ),
          child: Row(
            children: const [
              Icon(Icons.verified_rounded, size: 36, color: Colors.amber),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PRO Member Active',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'All anime templates & ad-free tracing active.',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              PremiumBadge(),
            ],
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.premiumGradient,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withValues(alpha: 0.3),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                PremiumBadge(fontSize: 11),
                SizedBox(width: 8),
                Text(
                  'ArtTrace PRO Access',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Unlock 500+ Sketches & 0 Ads',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Unlimited anime, cartoon, and realism masterclasses with offline support.',
              style: TextStyle(color: Colors.white, fontSize: 12, height: 1.3),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.openPremium,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFE65100),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(
                    inherit: false,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: Color(0xFFE65100),
                  ),
                ),
                child: const Text('View Plans & Pricing'),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildCardGroup(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.borderDark
              : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: Column(children: children),
      ),
    );
  }

  Widget _buildThemeOption(BuildContext context, String mode, String label, IconData icon) {
    final isSelected = controller.currentTheme.value == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.setTheme(mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.15)
                : (Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1E202B)
                    : const Color(0xFFF1F3FA)),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: isSelected ? AppColors.primary : null),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

