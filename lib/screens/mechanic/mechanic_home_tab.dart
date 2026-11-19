import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/ui.dart';
import '../../state/app_state.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/paywall_sheet.dart';
import '../customer/checklist_screen.dart';
import '../shared/price_chart_screen.dart';
import '../shared/subscription_screen.dart';

class MechanicHomeTab extends StatelessWidget {
  final VoidCallback? onOpenRequests;

  const MechanicHomeTab({super.key, this.onOpenRequests});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final active = appState.activeRequest;
        return ListView(
          padding: const EdgeInsets.only(bottom: 110),
          children: [
            _Header(),
            Transform.translate(
              offset: const Offset(0, -50),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _EarningsCard(),
                    if (active != null) ...[
                      const SizedBox(height: 14),
                      _ActiveJobCard(
                        customer: active.customerName,
                        vehicle: active.vehicle,
                        problem: active.problem,
                        payout: active.payout,
                      ),
                    ],
                    if (!appState.mechanicHasAccess) ...[
                      const SizedBox(height: 16),
                      PremiumBanner(
                        title: 'Grow your garage',
                        subtitle:
                            'Unlimited requests, priority placement and digital billing.',
                        onTap: () => Navigator.of(context)
                            .push(riseRoute(const SubscriptionScreen())),
                      ),
                    ],
                    const SectionHeader(
                      title: 'Quick actions',
                      padding: EdgeInsets.fromLTRB(2, 22, 2, 10),
                    ),
                    _QuickActions(onOpenRequests: onOpenRequests),
                    const SectionHeader(
                      title: 'Today at a glance',
                      padding: EdgeInsets.fromLTRB(2, 22, 2, 10),
                    ),
                    _StatsGrid(),
                    const SizedBox(height: 16),
                    _TipsCard(),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.navyGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(34)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 22, 20, 72),
      child: Stack(
        children: [
          Positioned(
            right: 26,
            top: -20,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.amber.withOpacity(0.08),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CarAidLogo(size: 36, light: true),
                  const Spacer(),
                  CircleIconButton(
                    icon: Icons.notifications_none_rounded,
                    size: 40,
                    background: AppColors.white.withOpacity(0.12),
                    foreground: AppColors.white,
                    onPressed: () => showAppSnack(
                        context, '${appState.requests.length} new job requests.'),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              Text(
                'Welcome back, ${appState.firstName}!',
                style: AppText.display(25, color: AppColors.white),
              ),
              const SizedBox(height: 5),
              Text(
                'Your garage is ${appState.online ? 'open for business' : 'currently offline'}.',
                style: AppText.body(
                    size: 12.5, color: AppColors.white.withOpacity(0.68)),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => appState.setOnline(!appState.online),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: appState.online
                            ? AppColors.teal.withOpacity(0.18)
                            : AppColors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: appState.online
                              ? AppColors.teal
                              : AppColors.white.withOpacity(0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: appState.online
                                  ? AppColors.teal
                                  : AppColors.faint,
                            ),
                          ),
                          const SizedBox(width: 7),
                          Text(
                            appState.online ? 'Online · accepting jobs' : 'Offline',
                            style: AppText.label(
                              size: 11.5,
                              color: appState.online
                                  ? AppColors.teal
                                  : AppColors.white.withOpacity(0.8),
                              weight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 14, color: AppColors.amber),
                        const SizedBox(width: 5),
                        Text(
                          '${appState.mechanicRating} rating',
                          style: AppText.label(
                              size: 11.5, color: AppColors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EarningsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      gradient: AppColors.tealGradient,
      borderColor: Colors.transparent,
      shadow: AppColors.liftShadow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Today’s earnings',
                style: AppText.body(
                    size: 12.5, color: AppColors.white.withOpacity(0.82)),
              ),
              const Spacer(),
              const Icon(Icons.trending_up_rounded,
                  color: AppColors.white, size: 19),
            ],
          ),
          const SizedBox(height: 6),
          Text(money(appState.todayEarnings),
              style: AppText.display(34, color: AppColors.white)),
          const SizedBox(height: 14),
          Row(
            children: [
              _chip(Icons.work_outline_rounded, '${appState.jobsToday} jobs'),
              const SizedBox(width: 8),
              _chip(Icons.schedule_rounded, 'This week ${money(appState.weekEarnings)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 13, color: AppColors.white),
          const SizedBox(width: 5),
          Text(label,
              style: AppText.body(
                  size: 10.5,
                  color: AppColors.white,
                  weight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ActiveJobCard extends StatelessWidget {
  final String customer;
  final String vehicle;
  final String problem;
  final int payout;

  const _ActiveJobCard({
    required this.customer,
    required this.vehicle,
    required this.problem,
    required this.payout,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      color: AppColors.amberSoft,
      borderColor: AppColors.amber.withOpacity(0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const IconTile(
                  icon: Icons.local_shipping_outlined,
                  color: AppColors.orange),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Active job',
                        style: TextStyle(
                            fontSize: 13.5, fontWeight: FontWeight.w800)),
                    Text('$customer · $vehicle',
                        style: AppText.body(
                            size: 11.5, color: AppColors.muted)),
                  ],
                ),
              ),
              Text(money(payout), style: AppText.price(size: 17)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            problem,
            style: AppText.body(
                size: 12.5,
                color: AppColors.ink,
                weight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: 'Open service checklist',
            icon: Icons.checklist_rounded,
            height: 46,
            onPressed: () => Navigator.of(context).push(
              riseRoute(const ChecklistScreen(roleContext: 'mechanic')),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final VoidCallback? onOpenRequests;

  const _QuickActions({this.onOpenRequests});

  @override
  Widget build(BuildContext context) {
    final actions = [
      (
        icon: Icons.markunread_mailbox_outlined,
        label: 'Requests',
        color: AppColors.blue,
        count: appState.requests.length,
      ),
      (
        icon: Icons.calculate_rounded,
        label: 'Price chart',
        color: AppColors.amber,
        count: null,
      ),
      (
        icon: Icons.chat_bubble_outline_rounded,
        label: 'Messages',
        color: AppColors.purple,
        count: null,
      ),
    ];

    return Row(
      children: actions.map((action) {
        return Expanded(
          child: AppCard(
            onTap: () {
              if (action.label == 'Price chart') {
                Navigator.of(context)
                    .push(riseRoute(const PriceChartScreen()));
              } else if (action.label == 'Requests') {
                onOpenRequests?.call();
              } else {
                showAppSnack(context, 'Chat opens from an active job.');
              }
            },
            padding: const EdgeInsets.symmetric(vertical: 14),
            margin: const EdgeInsets.only(right: 8),
            child: Column(
              children: [
                Stack(
                  children: [
                    Icon(action.icon, size: 22, color: action.color),
                    if (action.count != null && action.count! > 0)
                      Positioned(
                        right: -8,
                        top: -6,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                              color: AppColors.coral, shape: BoxShape.circle),
                          child: Text(
                            '${action.count}',
                            style: AppText.label(
                                size: 8, color: AppColors.white),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(action.label,
                    style: AppText.body(
                        size: 11, weight: FontWeight.w600)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final stats = [
      ('Week', money(appState.weekEarnings), Icons.calendar_today_rounded, AppColors.blue),
      ('Month', money(appState.monthEarnings), Icons.date_range_rounded, AppColors.purple),
      ('Rating', '${appState.mechanicRating}', Icons.star_rounded, AppColors.amber),
      ('Jobs', '${appState.jobsToday}', Icons.work_outline_rounded, AppColors.teal),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.5,
      children: stats.map((stat) {
        return AppCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              IconTile(
                icon: stat.$3,
                color: stat.$4,
                size: 40,
                radius: 12,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(stat.$1,
                        style:
                            AppText.body(size: 11, color: AppColors.muted)),
                    const SizedBox(height: 3),
                    Text(stat.$2,
                        style: AppText.body(
                            size: 15, weight: FontWeight.w800)),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _TipsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      color: AppColors.blue.withOpacity(0.04),
      borderColor: AppColors.blue.withOpacity(0.18),
      child: Row(
        children: [
          const IconTile(icon: Icons.tips_and_updates_outlined,
              color: AppColors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Earn more with Premium',
                    style: AppText.body(size: 13, weight: FontWeight.w700)),
                Text(
                  'Mechanics on Premium get priority placement in nearby search.',
                  style: AppText.body(
                      size: 11, color: AppColors.muted, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
