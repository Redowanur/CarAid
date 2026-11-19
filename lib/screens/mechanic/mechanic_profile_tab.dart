import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/ui.dart';
import '../../state/app_state.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_logo.dart';
import '../auth_screen.dart';
import '../shared/subscription_screen.dart';

class MechanicProfileTab extends StatelessWidget {
  const MechanicProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final hasAccess = appState.mechanicHasAccess;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Garage profile'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded),
                onPressed: () => _confirmSignOut(context),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
            children: [
              AppCard(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        gradient: AppColors.amberGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        initials(appState.name),
                        style: AppText.display(22, color: AppColors.white),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(appState.name, style: AppText.h2()),
                          const SizedBox(height: 2),
                          Text(appState.email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.body(
                                  size: 11.5, color: AppColors.muted)),
                          const SizedBox(height: 7),
                          const StatusPill(
                            label: 'VERIFIED MECHANIC',
                            color: AppColors.teal,
                            icon: Icons.verified_rounded,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.all(18),
                gradient: hasAccess
                    ? AppColors.premiumGradient
                    : AppColors.navyGradient,
                borderColor: Colors.transparent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.amber.withOpacity(0.16),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.workspace_premium_rounded,
                              color: AppColors.amber, size: 21),
                        ),
                        const SizedBox(width: 10),
                        StatusPill(
                          label: appState.accessLabel,
                          color: hasAccess ? AppColors.teal : AppColors.amber,
                          icon: hasAccess
                              ? Icons.verified_rounded
                              : Icons.lock_outline_rounded,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      hasAccess
                          ? 'Your Premium garage is live'
                          : 'Get more jobs with Premium',
                      style: AppText.h2(color: AppColors.white),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      hasAccess
                          ? 'You appear higher in nearby searches and can bill digitally.'
                          : 'Try 7 days free. Then ৳299/month. Cancel anytime.',
                      style: AppText.body(
                        size: 12.5,
                        color: AppColors.white.withOpacity(0.72),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      label: hasAccess ? 'Manage plan' : 'Start free trial',
                      icon: Icons.arrow_forward_rounded,
                      height: 46,
                      onPressed: () => Navigator.of(context)
                          .push(riseRoute(const SubscriptionScreen())),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Text('Garage details', style: AppText.h3()),
              const SizedBox(height: 10),
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Column(
                  children: [
                    _row(Icons.build_outlined, 'Garage', 'Rahim Auto Care'),
                    _row(Icons.star_outline_rounded, 'Rating',
                        '${appState.mechanicRating} / 5'),
                    _row(Icons.work_outline_rounded, 'Jobs completed',
                        '${appState.jobsToday} today'),
                    _row(Icons.phone_outlined, 'Phone', appState.phone),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Column(
                  children: [
                    _tile(
                      icon: Icons.account_balance_wallet_outlined,
                      color: AppColors.teal,
                      title: 'Earnings & payouts',
                      subtitle: 'View your digital receipts',
                      onTap: () => showAppSnack(
                        context,
                        'Open the Earnings tab to see payouts.',
                      ),
                    ),
                    _tile(
                      icon: Icons.help_outline_rounded,
                      color: AppColors.coral,
                      title: 'Help & support',
                      subtitle: 'Call 16358 · 8am – 10pm',
                      onTap: () => showAppSnack(
                        context,
                        'CarAid support: 16358',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Center(
                child: Column(
                  children: [
                    const CarAidLogo(size: 32),
                    const SizedBox(height: 6),
                    Text('CarAid · Mechanic demo',
                        style:
                            AppText.body(size: 11, color: AppColors.faint)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, size: 19, color: AppColors.faint),
      title: Text(label, style: AppText.body(size: 12, color: AppColors.muted)),
      trailing: Text(value,
          style: AppText.body(size: 12.5, weight: FontWeight.w700)),
    );
  }

  Widget _tile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: IconTile(icon: icon, color: color, size: 42),
      title:
          Text(title, style: AppText.body(size: 13.5, weight: FontWeight.w700)),
      subtitle: Text(subtitle,
          style: AppText.body(size: 11, color: AppColors.muted)),
      trailing: const Icon(Icons.chevron_right_rounded,
          size: 20, color: AppColors.faint),
      onTap: onTap,
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text('Sign out?', style: AppText.h2()),
        content: Text(
          'You will need to sign in again to continue.',
          style: AppText.body(size: 13, color: AppColors.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                Text('Cancel', style: AppText.label(color: AppColors.muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                Text('Sign out', style: AppText.label(color: AppColors.coral)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await appState.signOut();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        riseRoute(const AuthScreen()),
        (route) => false,
      );
    }
  }
}
