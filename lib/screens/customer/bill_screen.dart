import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/ui.dart';
import '../../models/booking.dart';
import '../../state/app_state.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import 'payment_screen.dart';

/// Digital, itemized bill shown after the mechanic completes a service.
class BillScreen extends StatelessWidget {
  const BillScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final record = appState.currentBooking;
        final lines = record?.doneLines ?? appState.doneLines;
        final travel = record?.travelFee ?? appState.travelFee;
        final servicesTotal = lines.fold(0, (sum, line) => sum + line.amount);
        final total = servicesTotal + travel;
        final paid = record?.status == BookingStatus.paid;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Service bill'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              _BillHeader(
                id: record?.id ?? appState.requestId,
                date: record?.date ?? DateTime.now(),
                paid: paid,
                method: record?.method,
              ),
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.tealSoft,
                      child: Text(
                        initials(appState.mechanic?.name ?? 'CM'),
                        style: AppText.label(
                          size: 12,
                          color: AppColors.tealDark,
                          weight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appState.mechanic?.name ?? 'CarAid mechanic',
                            style: AppText.body(
                                size: 14, weight: FontWeight.w700),
                          ),
                          Text(
                            '${appState.mechanic?.garage ?? 'Verified partner'} · ${appState.selectedVehicle.name}',
                            style: AppText.body(
                                size: 11.5, color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.verified_rounded,
                        color: AppColors.teal, size: 20),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text('Itemized services', style: AppText.h3()),
                  const Spacer(),
                  StatusPill(
                    label: '${lines.length} ITEMS',
                    color: AppColors.blue,
                    icon: Icons.receipt_long_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              AppCard(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                child: Column(
                  children: [
                    if (lines.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          'No services were marked as completed.',
                          style: AppText.body(
                              size: 12.5, color: AppColors.muted),
                        ),
                      ),
                    ...lines.map(
                      (line) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 1),
                              child: Icon(Icons.check_circle_rounded,
                                  size: 17, color: AppColors.teal),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(line.name,
                                      style: AppText.body(
                                          size: 13, weight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  Text('Service charge',
                                      style: AppText.body(
                                          size: 10.5, color: AppColors.faint)),
                                ],
                              ),
                            ),
                            Text(money(line.amount),
                                style: AppText.body(
                                    size: 13, weight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              AppCard(
                padding: const EdgeInsets.all(16),
                color: AppColors.blue.withOpacity(0.04),
                borderColor: AppColors.blue.withOpacity(0.18),
                child: Row(
                  children: [
                    const IconTile(
                        icon: Icons.two_wheeler_rounded, color: AppColors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Mechanic travel',
                              style: AppText.body(
                                  size: 13, weight: FontWeight.w700)),
                          Text(
                            'Base ৳60 + ৳18/km · ${distance(appState.travelDistanceKm)}',
                            style: AppText.body(
                                size: 11, color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                    Text(money(travel), style: AppText.price(size: 16)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              AppCard(
                padding: const EdgeInsets.all(18),
                gradient: AppColors.navyGradient,
                borderColor: Colors.transparent,
                child: Column(
                  children: [
                    _totalRow('Services', money(servicesTotal)),
                    const SizedBox(height: 10),
                    _totalRow('Travel', money(travel)),
                    const SizedBox(height: 10),
                    _totalRow('Platform fee', '৳0', color: AppColors.teal),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Divider(color: Colors.white24),
                    ),
                    Row(
                      children: [
                        Text('Total due',
                            style: AppText.body(
                                size: 14, color: AppColors.white)),
                        const Spacer(),
                        Text(money(total),
                            style: AppText.display(
                                30,
                                color: paid ? AppColors.teal : AppColors.amber,
                            )),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  'Prices are confirmed by the mechanic after inspection.\nBDT only · All taxes included.',
                  textAlign: TextAlign.center,
                  style: AppText.body(
                    size: 10.5,
                    color: AppColors.faint,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (paid)
                PrimaryButton(
                  label: 'Back to home',
                  icon: Icons.home_outlined,
                  onPressed: () => Navigator.of(context)
                      .popUntil((route) => route.isFirst),
                )
              else
                PrimaryButton(
                  label: 'Pay ${money(total)}',
                  icon: Icons.account_balance_wallet_outlined,
                  onPressed: () => Navigator.of(context)
                      .push(riseRoute(const PaymentScreen())),
                ),
              const SizedBox(height: 10),
              SecondaryButton(
                label: 'Back to tracking',
                icon: Icons.my_location_outlined,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _totalRow(String label, String value, {Color color = Colors.white}) {
    return Row(
      children: [
        Text(label,
            style: AppText.body(size: 12.5, color: Colors.white.withOpacity(0.7))),
        const Spacer(),
        Text(value,
            style: AppText.body(
                size: 12.5,
                weight: FontWeight.w700,
                color: color == Colors.white ? Colors.white : color)),
      ],
    );
  }
}

class _BillHeader extends StatelessWidget {
  final String id;
  final DateTime date;
  final bool paid;
  final dynamic method;

  const _BillHeader({
    required this.id,
    required this.date,
    required this.paid,
    required this.method,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: paid ? AppColors.tealGradient : AppColors.amberGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  paid
                      ? Icons.check_circle_outline_rounded
                      : Icons.receipt_long_rounded,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      paid ? 'Payment complete' : 'Ready for payment',
                      style: AppText.h2(),
                    ),
                    Text(
                      paid ? 'Thank you for choosing CarAid.' : 'Review your final bill below.',
                      style: AppText.body(size: 12, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cloud,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _meta('BILL ID', id),
                ),
                Container(width: 1, height: 30, color: AppColors.border),
                const SizedBox(width: 14),
                Expanded(
                  child: _meta('DATE', shortDate(date)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _meta(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.label(size: 9.5, letterSpacing: 1)),
        const SizedBox(height: 3),
        Text(value,
            style: AppText.body(size: 12, weight: FontWeight.w700),
            overflow: TextOverflow.ellipsis),
      ],
    );
  }
}
