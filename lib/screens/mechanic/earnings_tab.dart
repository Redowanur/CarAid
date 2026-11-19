import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/ui.dart';
import '../../models/booking.dart';
import '../../models/payment_method.dart';
import '../../state/app_state.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';

class EarningsTab extends StatelessWidget {
  const EarningsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Earnings'),
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline_rounded),
                onPressed: () => showAppSnack(
                    context, 'Earnings include service charges + travel.'),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
            children: [
              _EarningsHero(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _SmallStat(
                      label: 'This week',
                      value: money(appState.weekEarnings),
                      icon: Icons.calendar_today_rounded,
                      color: AppColors.blue,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SmallStat(
                      label: 'This month',
                      value: money(appState.monthEarnings),
                      icon: Icons.date_range_rounded,
                      color: AppColors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Text('Recent payouts', style: AppText.h3()),
                  const Spacer(),
                  Text(
                    '${appState.payouts.length} records',
                    style: AppText.body(size: 11, color: AppColors.faint),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...appState.payouts.map(
                (record) => _PayoutCard(record: record),
              ),
              const SizedBox(height: 14),
              SecondaryButton(
                label: 'Withdraw earnings',
                icon: Icons.account_balance_outlined,
                onPressed: () => showAppSnack(
                  context,
                  'Payouts are simulated in this demo.',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EarningsHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      gradient: AppColors.navyGradient,
      borderColor: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_outlined,
                  color: AppColors.amber, size: 20),
              const SizedBox(width: 8),
              Text(
                'Available balance',
                style: AppText.body(
                    size: 12, color: AppColors.white.withOpacity(0.72)),
              ),
              const Spacer(),
              const StatusPill(
                label: 'READY',
                color: AppColors.teal,
                icon: Icons.check_circle_rounded,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(money(appState.todayEarnings),
              style: AppText.display(36, color: AppColors.white)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _mini('Jobs today', '${appState.jobsToday}'),
              ),
              Expanded(
                child: _mini('Avg. rating', '${appState.mechanicRating}'),
              ),
              Expanded(
                child: _mini('Travel included', 'Yes'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mini(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppText.body(
                  size: 9.5, color: AppColors.white.withOpacity(0.6))),
          const SizedBox(height: 3),
          Text(value,
              style: AppText.body(
                  size: 12.5,
                  color: AppColors.white,
                  weight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _SmallStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SmallStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          IconTile(icon: icon, color: color, size: 40, radius: 12),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppText.body(size: 11, color: AppColors.muted)),
                Text(value,
                    style: AppText.body(size: 15, weight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PayoutCard extends StatelessWidget {
  final BookingRecord record;

  const _PayoutCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const IconTile(
                  icon: Icons.receipt_long_outlined,
                  color: AppColors.teal,
                  size: 42),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(record.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.body(
                            size: 13, weight: FontWeight.w700)),
                    Text(
                      '${record.vehicle} · ${shortDate(record.date)}',
                      style: AppText.body(
                          size: 10.5, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              Text('+${money(record.total)}',
                  style: AppText.price(size: 16, color: AppColors.tealDark)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              StatusPill(
                label: 'PAID VIA ${record.method?.label.toUpperCase() ?? 'CASH'}',
                color: AppColors.blue,
                icon: Icons.check_circle_outlined,
              ),
              const Spacer(),
              Text(
                'Travel ${money(record.travelFee)} · ${record.txn ?? '—'}',
                style: AppText.body(size: 10, color: AppColors.faint),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
