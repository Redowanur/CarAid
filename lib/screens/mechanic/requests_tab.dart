import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/ui.dart';
import '../../models/booking.dart';
import '../../state/app_state.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/paywall_sheet.dart';
import '../customer/checklist_screen.dart';

class RequestsTab extends StatelessWidget {
  const RequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final active = appState.activeRequest;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Job requests'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Center(
                  child: StatusPill(
                    label: '${appState.requests.length} NEW',
                    color: appState.requests.isEmpty
                        ? AppColors.faint
                        : AppColors.coral,
                    icon: Icons.notifications_active_outlined,
                  ),
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
            children: [
              if (active != null)
                AppCard(
                  padding: const EdgeInsets.all(18),
                  color: AppColors.teal.withOpacity(0.06),
                  borderColor: AppColors.teal.withOpacity(0.28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle_outline_rounded,
                              color: AppColors.teal, size: 20),
                          const SizedBox(width: 8),
                          Text('Accepted job', style: AppText.h3()),
                          const Spacer(),
                          Text(money(active.payout),
                              style: AppText.price(size: 18)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${active.vehicle} · ${active.problem}',
                        style: AppText.body(
                            size: 12.5, color: AppColors.muted),
                      ),
                      const SizedBox(height: 14),
                      PrimaryButton(
                        label: 'Complete service & create bill',
                        icon: Icons.checklist_rounded,
                        height: 46,
                        onPressed: () => Navigator.of(context).push(
                          riseRoute(
                              const ChecklistScreen(roleContext: 'mechanic')),
                        ),
                      ),
                    ],
                  ),
                ),
              if (active != null) const SizedBox(height: 18),
              Row(
                children: [
                  Text('Nearby requests', style: AppText.h3()),
                  const Spacer(),
                  Text(
                    'Sorted by distance',
                    style: AppText.body(size: 11, color: AppColors.faint),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (appState.requests.isEmpty)
                AppCard(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 40),
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle_outline_rounded,
                          size: 38, color: AppColors.teal),
                      const SizedBox(height: 12),
                      Text('All caught up!', style: AppText.h3()),
                      const SizedBox(height: 5),
                      Text(
                        'New requests will appear here as customers book.',
                        textAlign: TextAlign.center,
                        style: AppText.body(
                            size: 12, color: AppColors.muted),
                      ),
                    ],
                  ),
                )
              else
                ...appState.requests.map(
                  (request) => _RequestCard(request: request),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _RequestCard extends StatelessWidget {
  final JobRequest request;

  const _RequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final minutesAgo = DateTime.now()
        .difference(request.createdAt)
        .inMinutes
        .clamp(1, 999);

    return AppCard(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.blueSoft,
                child: Text(
                  initials(request.customerName),
                  style: AppText.label(
                    size: 12,
                    color: AppColors.blue,
                    weight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(request.customerName,
                        style: AppText.body(
                            size: 13.5, weight: FontWeight.w700)),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 12, color: AppColors.faint),
                        const SizedBox(width: 3),
                        Text(request.area,
                            style: AppText.body(
                                size: 10.5, color: AppColors.muted)),
                      ],
                    ),
                  ],
                ),
              ),
              if (request.urgent)
                const StatusPill(
                  label: 'URGENT',
                  color: AppColors.coral,
                  icon: Icons.bolt_rounded,
                ),
            ],
          ),
          const SizedBox(height: 13),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cloud,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.directions_car_outlined,
                        size: 14, color: AppColors.teal),
                    const SizedBox(width: 6),
                    Text(request.vehicle,
                        style: AppText.body(
                            size: 12, weight: FontWeight.w600)),
                    const Spacer(),
                    Text(request.etaLabel,
                        style: AppText.body(
                            size: 11, color: AppColors.muted)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(request.problem,
                    style: AppText.body(size: 12.5, weight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Estimated payout',
                      style: AppText.body(
                          size: 10.5, color: AppColors.muted)),
                  Text(money(request.payout),
                      style: AppText.price(size: 19)),
                ],
              ),
              const Spacer(),
              Text('$minutesAgo min ago',
                  style: AppText.body(size: 10, color: AppColors.faint)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  label: 'Decline',
                  icon: Icons.close_rounded,
                  color: AppColors.muted,
                  height: 44,
                  onPressed: () {
                    appState.declineRequest(request.id);
                    showAppSnack(context, 'Request declined.');
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PrimaryButton(
                  label: 'Accept',
                  icon: Icons.check_rounded,
                  height: 44,
                  onPressed: () async {
                    final allowed = await ensureAccess(context);
                    if (!allowed) return;
                    appState.acceptRequest(request);
                    if (context.mounted) {
                      showAppSnack(
                        context,
                        'Job accepted. Open the checklist when done.',
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
