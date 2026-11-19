import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/ui.dart';
import '../data/demo_data.dart';
import '../models/vehicle_type.dart';
import '../screens/shared/subscription_screen.dart';
import '../state/app_state.dart';
import 'app_button.dart';

/// Returns true when the user either already has access or starts a trial.
Future<bool> ensureAccess(BuildContext context) async {
  if (appState.hasAccess) return true;

  final granted = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _PaywallSheet(),
  );
  return granted ?? false;
}

class _PaywallSheet extends StatelessWidget {
  const _PaywallSheet();

  @override
  Widget build(BuildContext context) {
    final isMechanic = appState.role == UserRole.mechanic;
    final monthlyPrice = isMechanic ? 299 : 199;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: EdgeInsets.fromLTRB(
          22, 12, 22, MediaQuery.of(context).padding.bottom + 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppColors.amberGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.lock_open_rounded,
                    color: AppColors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Unlock CarAid Premium', style: AppText.h2()),
                    Text(
                      isMechanic
                          ? 'Accept jobs and manage every service in one place.'
                          : 'Track your mechanic live and pay without cash.',
                      style: AppText.body(color: AppColors.muted, size: 12.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...premiumFeatures.take(4).map(
                (feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          size: 18, color: AppColors.teal),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(feature,
                            style: AppText.body(size: 13.5, height: 1.3)),
                      ),
                    ],
                  ),
                ),
              ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.tealSoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.card_giftcard_rounded,
                    color: AppColors.tealDark, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Start with 7 days free. Then ৳$monthlyPrice/month. Cancel anytime.',
                    style: AppText.body(
                        size: 12, color: AppColors.tealDark, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Start 7-day free trial',
            icon: Icons.bolt_rounded,
            onPressed: () {
              appState.startTrial();
              Navigator.pop(context, true);
            },
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () async {
                final result = await Navigator.of(context)
                    .push<bool>(riseRoute(const SubscriptionScreen()));
                if (result == true && context.mounted) {
                  Navigator.pop(context, true);
                }
              },
              child: Text(
                'Compare plans',
                style: AppText.label(
                  size: 13.5,
                  color: AppColors.muted,
                  weight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small reusable premium banner used on dashboards and profiles.
class PremiumBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const PremiumBanner({
    super.key,
    this.title = 'Go Premium',
    this.subtitle = 'Live tracking, chat, calls & cashless pay.',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ??
          () => Navigator.of(context).push(riseRoute(const SubscriptionScreen())),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: AppColors.premiumGradient,
          borderRadius: BorderRadius.circular(22),
          boxShadow: AppColors.liftShadow,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.amber.withOpacity(0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.workspace_premium_rounded,
                  color: AppColors.amber, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppText.body(
                          size: 14.5,
                          weight: FontWeight.w800,
                          color: AppColors.white)),
                  const SizedBox(height: 3),
                  Text(subtitle,
                      style: AppText.body(
                          size: 11.5,
                          color: AppColors.white.withOpacity(0.7),
                          height: 1.35)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded,
                color: AppColors.amber, size: 20),
          ],
        ),
      ),
    );
  }
}

void openSubscription(BuildContext context) {
  Navigator.of(context, rootNavigator: true)
      .push(riseRoute(const SubscriptionScreen()));
}
