import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/ui.dart';
import '../../state/app_state.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_logo.dart';
import '../auth_screen.dart';
import '../shared/maintenance_tips_screen.dart';
import '../shared/price_chart_screen.dart';
import '../shared/subscription_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final hasAccess = appState.hasAccess;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
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
              _ProfileHeader(),
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
                            color:
                                AppColors.amber.withOpacity(0.16),
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
                    const SizedBox(height: 16),
                    Text(
                      hasAccess
                          ? 'Premium is active'
                          : 'Unlock the full CarAid experience',
                      style: AppText.h2(color: AppColors.white),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      hasAccess
                          ? 'Live tracking, chat, calls and cashless payments are ready.'
                          : 'Start a 7-day free trial — no card required.',
                      style: AppText.body(
                        size: 12.5,
                        color: AppColors.white.withOpacity(0.7),
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
              Text('Account', style: AppText.h3()),
              const SizedBox(height: 10),
              AppCard(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                child: Column(
                  children: [
                    _tile(
                      icon: Icons.person_outline_rounded,
                      color: AppColors.blue,
                      title: 'Personal details',
                      subtitle: '${appState.email} · ${appState.phone}',
                      onTap: () => _showAccountDetails(context),
                    ),
                    _tile(
                      icon: Icons.history_rounded,
                      color: AppColors.teal,
                      title: 'Service history',
                      subtitle: '${appState.history.length} completed jobs',
                      onTap: () => showAppSnack(
                        context,
                        'Open the Jobs tab to see all receipts.',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text('Explore', style: AppText.h3()),
              const SizedBox(height: 10),
              AppCard(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                child: Column(
                  children: [
                    _tile(
                      icon: Icons.table_rows_rounded,
                      color: AppColors.blue,
                      title: 'Service price chart',
                      subtitle: 'Free · 30+ verified prices',
                      onTap: () => Navigator.of(context)
                          .push(riseRoute(const PriceChartScreen())),
                    ),
                    _tile(
                      icon: Icons.lightbulb_outline_rounded,
                      color: AppColors.amber,
                      title: 'Maintenance tips',
                      subtitle: 'Free · Keep your car healthy',
                      onTap: () => Navigator.of(context)
                          .push(riseRoute(const MaintenanceTipsScreen())),
                    ),
                    _tile(
                      icon: Icons.workspace_premium_rounded,
                      color: AppColors.purple,
                      title: 'Compare plans',
                      subtitle: 'Monthly and yearly pricing',
                      onTap: () => Navigator.of(context)
                          .push(riseRoute(const SubscriptionScreen())),
                    ),
                    _tile(
                      icon: Icons.support_agent_rounded,
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
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    const CarAidLogo(size: 32),
                    const SizedBox(height: 6),
                    Text(
                      'CarAid · Demo experience',
                      style: AppText.body(size: 11, color: AppColors.faint),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
      title: Text(title,
          style: AppText.body(size: 13.5, weight: FontWeight.w700)),
      subtitle: Text(subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppText.body(size: 11, color: AppColors.muted)),
      trailing: const Icon(Icons.chevron_right_rounded,
          size: 20, color: AppColors.faint),
      onTap: onTap,
    );
  }

  void _showAccountDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(
            22, 14, 22, MediaQuery.of(context).padding.bottom + 24),
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
            const SizedBox(height: 18),
            Text('Personal details', style: AppText.h2()),
            const SizedBox(height: 14),
            _detailRow('Name', appState.name),
            _detailRow('Email', appState.email),
            _detailRow('Phone', appState.phone),
            _detailRow('Account', appState.isDemoSession ? 'Demo' : 'Firebase'),
            _detailRow('UID', appState.uid),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: AppText.body(size: 12, color: AppColors.muted))),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: AppText.body(size: 12.5, weight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
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
            child: Text('Cancel',
                style: AppText.label(color: AppColors.muted, size: 13)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Sign out',
                style: AppText.label(color: AppColors.coral, size: 13)),
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

class _ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              gradient: AppColors.tealGradient,
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
                    style: AppText.body(size: 12, color: AppColors.muted)),
                const SizedBox(height: 8),
                const StatusPill(
                  label: 'VERIFIED CUSTOMER',
                  color: AppColors.teal,
                  icon: Icons.verified_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
