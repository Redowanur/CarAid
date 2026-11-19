import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/ui.dart';
import '../../models/booking.dart';
import '../../models/payment_method.dart';
import '../../state/app_state.dart';
import '../../widgets/app_card.dart';
import '../customer/tracking_screen.dart';

class ActivityTab extends StatefulWidget {
  const ActivityTab({super.key});

  @override
  State<ActivityTab> createState() => _ActivityTabState();
}

class _ActivityTabState extends State<ActivityTab> {
  int _filter = 0;
  static const _filters = ['All', 'Paid', 'Others'];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final all = appState.history;
        final records = _filter == 0
            ? all
            : all
                .where((r) => _filter == 1
                    ? r.status == BookingStatus.paid
                    : r.status != BookingStatus.paid)
                .toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Your jobs'),
            actions: [
              IconButton(
                icon: const Icon(Icons.help_outline_rounded),
                onPressed: () => showAppSnack(
                    context, 'Need help? Call CarAid support at 16358.'),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Row(
                  children: List.generate(_filters.length, (index) {
                    final active = _filter == index;
                    return Padding(
                      padding: EdgeInsets.only(right: index == 2 ? 0 : 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _filter = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: active ? AppColors.ink : AppColors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color:
                                  active ? AppColors.ink : AppColors.border,
                            ),
                          ),
                          child: Text(
                            _filters[index],
                            style: AppText.label(
                              size: 12,
                              color: active
                                  ? AppColors.white
                                  : AppColors.muted,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              if (_hasOngoingJob())
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: AppCard(
                    onTap: () => Navigator.of(context)
                        .push(riseRoute(const TrackingScreen(freshBooking: false))),
                    padding: const EdgeInsets.all(14),
                    color: AppColors.amberSoft,
                    borderColor: AppColors.amber.withOpacity(0.35),
                    child: Row(
                      children: [
                        const Icon(Icons.local_shipping_outlined,
                            color: AppColors.orange, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Ongoing service',
                                  style: AppText.body(
                                      size: 13, weight: FontWeight.w800)),
                              Text(appState.status.label,
                                  style: AppText.body(
                                      size: 11, color: AppColors.muted)),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_rounded,
                            size: 18, color: AppColors.orange),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: records.isEmpty
                    ? const _EmptyJobs()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
                        itemCount: records.length,
                        itemBuilder: (context, index) =>
                            _JobCard(record: records[index]),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _hasOngoingJob() {
    switch (appState.status) {
      case BookingStatus.searching:
      case BookingStatus.enRoute:
      case BookingStatus.arrived:
      case BookingStatus.inProgress:
      case BookingStatus.completed:
        return true;
      default:
        return false;
    }
  }
}

class _JobCard extends StatelessWidget {
  final BookingRecord record;

  const _JobCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final paid = record.status == BookingStatus.paid;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        onTap: () => _showDetail(context),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: paid ? AppColors.tealSoft : AppColors.amberSoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.build_circle_outlined,
                    color: paid ? AppColors.tealDark : AppColors.orange,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(record.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.body(
                              size: 13.5, weight: FontWeight.w700)),
                      Text(shortDate(record.date),
                          style: AppText.body(
                              size: 11, color: AppColors.muted)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(money(record.total),
                        style: AppText.price(size: 17)),
                    const SizedBox(height: 3),
                    StatusPill(
                      label: paid ? 'PAID' : record.status.label.toUpperCase(),
                      color: paid ? AppColors.teal : AppColors.amber,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.cloud,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.directions_car_outlined,
                      size: 13, color: AppColors.faint),
                  const SizedBox(width: 5),
                  Text(record.vehicle,
                      style: AppText.body(size: 10.5, color: AppColors.muted)),
                  const Spacer(),
                  Icon(Icons.person_outline_rounded,
                      size: 13, color: AppColors.faint),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      record.mechanicName,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.body(size: 10.5, color: AppColors.muted),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
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
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 18),
            Text(record.title, style: AppText.h2()),
            const SizedBox(height: 4),
            Text('${record.id} · ${shortDate(record.date)}',
                style: AppText.body(size: 11.5, color: AppColors.muted)),
            const SizedBox(height: 18),
            ...record.doneLines.map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        size: 16, color: AppColors.teal),
                    const SizedBox(width: 9),
                    Expanded(
                        child: Text(line.name,
                            style: AppText.body(size: 12.5))),
                    Text(money(line.amount),
                        style: AppText.body(
                            size: 12.5, weight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(
                children: [
                  const Icon(Icons.two_wheeler_rounded,
                      size: 16, color: AppColors.blue),
                  const SizedBox(width: 9),
                  const Expanded(
                      child: Text('Mechanic travel',
                          style: TextStyle(fontSize: 12.5))),
                  Text(money(record.travelFee),
                      style: AppText.body(size: 12.5, weight: FontWeight.w600)),
                ],
              ),
            ),
            const Divider(height: 18),
            Row(
              children: [
                Text('Total', style: AppText.body(size: 14)),
                const Spacer(),
                Text(money(record.total), style: AppText.display(24)),
              ],
            ),
            if (record.txn != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cloud,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.receipt_long_outlined,
                        size: 16, color: AppColors.faint),
                    const SizedBox(width: 8),
                    Text('Txn ${record.txn} · ${record.method?.label ?? 'Cash'}',
                        style: AppText.body(
                            size: 11.5, color: AppColors.muted)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyJobs extends StatelessWidget {
  const _EmptyJobs();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
                color: AppColors.white, shape: BoxShape.circle),
            child: const Icon(Icons.receipt_long_outlined,
                size: 34, color: AppColors.faint),
          ),
          const SizedBox(height: 16),
          Text('No jobs here yet', style: AppText.h3()),
          const SizedBox(height: 6),
          Text(
            'Book a mechanic and your receipts will appear here.',
            style: AppText.body(size: 12.5, color: AppColors.muted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
