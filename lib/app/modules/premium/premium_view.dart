import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/widgets/premium_badge.dart';
import '../../theme/app_colors.dart';
import 'premium_controller.dart';

class PremiumView extends GetView<PremiumController> {
  const PremiumView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1016),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Close & Restore
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70),
                      onPressed: () => Get.back(),
                    ),
                    TextButton(
                      onPressed: controller.restorePurchases,
                      child: const Text(
                        'Restore Purchases',
                        style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

              // Hero Illustration & Badge
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: AppColors.premiumGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withValues(alpha: 0.4),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const PremiumBadge(fontSize: 12),
                    const SizedBox(height: 12),
                    const Text(
                      'ArtTrace PRO',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Master drawing with all templates & zero distractions.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Feature Highlights List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildFeatureRow(Icons.auto_awesome_rounded, '500+ Anime & Pro Sketches', 'Full library unlocked forever'),
                    const SizedBox(height: 12),
                    _buildFeatureRow(Icons.block_rounded, '100% Ad-Free Tracing', 'Never interrupted while tracing'),
                    const SizedBox(height: 12),
                    _buildFeatureRow(Icons.school_rounded, 'Step-by-Step Masterclasses', 'Stage guides with AR paper alignment'),
                    const SizedBox(height: 12),
                    _buildFeatureRow(Icons.add_photo_alternate_rounded, 'Unlimited Photo Imports', 'Trace any photo from your camera roll'),
                    const SizedBox(height: 12),
                    _buildFeatureRow(Icons.palette_rounded, 'Exclusive High-Contrast Filters', 'Inverted white, neon, and line boost'),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Pricing Plans Selection
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: controller.fallbackPlans.map((plan) {
                    return _buildPlanCard(context, plan);
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // Action Purchase Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: controller.purchaseSelectedPlan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      elevation: 6,
                      shadowColor: Colors.orange.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    child: const Text(
                      'Unlock All Features Now',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: -0.2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Footnotes & Security disclaimer
              Center(
                child: Column(
                  children: const [
                    Text(
                      'Billed securely via Google Play. Cancel anytime.',
                      style: TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Auto-renews unless cancelled 24h prior to renewal date.',
                      style: TextStyle(color: Colors.white24, fontSize: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.orangeAccent, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard(BuildContext context, PremiumPlan plan) {
    return Obx(() {
      final isSelected = controller.selectedPlanId.value == plan.id;

      return GestureDetector(
        onTap: () => controller.selectPlan(plan.id),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF262038) : const Color(0xFF191B24),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? Colors.orange : Colors.white12,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                color: isSelected ? Colors.orange : Colors.white38,
                size: 22,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          plan.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        if (plan.discountTag != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              plan.discountTag!,
                              style: const TextStyle(
                                color: Colors.orangeAccent,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      plan.period,
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                plan.price,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

