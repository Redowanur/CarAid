import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/demo_data.dart';
import '../../widgets/app_card.dart';

class MaintenanceTipsScreen extends StatelessWidget {
  const MaintenanceTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Maintenance tips')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        children: [
          AppCard(
            padding: const EdgeInsets.all(18),
            gradient: AppColors.tealGradient,
            borderColor: Colors.transparent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.lightbulb_outline_rounded,
                          color: AppColors.white, size: 22),
                    ),
                    const SizedBox(width: 10),
                    const StatusPill(
                      label: 'FREE',
                      color: AppColors.white,
                      icon: Icons.lock_open_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Small habits, big savings.',
                  style: AppText.display(24, color: AppColors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  'A little care every month keeps your vehicle reliable in Dhaka traffic.',
                  style: AppText.body(
                    size: 12.5,
                    color: AppColors.white.withOpacity(0.82),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ...maintenanceTips.asMap().entries.map(
                (entry) => _TipCard(
                  index: entry.key + 1,
                  tip: entry.value,
                ),
              ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final int index;
  final MaintenanceTip tip;

  const _TipCard({required this.index, required this.tip});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: tip.accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(15),
            ),
            alignment: Alignment.center,
            child: Icon(tip.icon, size: 23, color: tip.accent),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        tip.title,
                        style: AppText.body(
                            size: 14, weight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      '#$index',
                      style: AppText.label(size: 11, color: AppColors.faint),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  tip.body,
                  style: AppText.body(
                    size: 12.5,
                    color: AppColors.muted,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
