import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/ui.dart';
import '../../data/demo_data.dart';
import '../../models/payment_method.dart';
import '../../state/app_state.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import 'customer_shell.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethod _method = PaymentMethod.bkash;
  bool _processing = false;

  int get _total => appState.billTotal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose payment method'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                _amountCard(),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Text('Pay with', style: AppText.h3()),
                    const Spacer(),
                    const StatusPill(
                      label: 'SIMULATED',
                      color: AppColors.amber,
                      icon: Icons.science_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'No real money is charged. Pick any method to preview the flow.',
                  style: AppText.body(size: 12, color: AppColors.muted),
                ),
                const SizedBox(height: 14),
                ...paymentMethods.map(_methodTile),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.blueSoft,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_outline_rounded,
                          size: 18, color: AppColors.blue),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'A receipt with a transaction ID will be saved to your service history.',
                          style: AppText.body(
                            size: 11.5,
                            color: AppColors.blue,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: AppColors.white,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            padding: EdgeInsets.fromLTRB(
                20, 14, 20, MediaQuery.of(context).padding.bottom + 16),
            child: SafeArea(
              top: false,
              child: PrimaryButton(
                label: 'Pay ${money(_total)} with ${_method.label}',
                icon: Icons.lock_open_rounded,
                loading: _processing,
                onPressed: _pay,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _amountCard() {
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
                'Amount due',
                style: AppText.body(
                    size: 12, color: AppColors.white.withOpacity(0.7)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(money(_total), style: AppText.display(38, color: AppColors.white)),
          const SizedBox(height: 14),
          Row(
            children: [
              _miniStat(Icons.build_outlined,
                  'Services ${money(appState.doneServicesTotal)}'),
              const SizedBox(width: 8),
              _miniStat(Icons.two_wheeler_rounded,
                  'Travel ${money(appState.travelFee)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 13, color: AppColors.teal),
          const SizedBox(width: 5),
          Text(label,
              style: AppText.body(
                  size: 10.5,
                  color: AppColors.white.withOpacity(0.85),
                  weight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _methodTile(PaymentMethod method) {
    final selected = _method == method;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        onTap: () => setState(() => _method = method),
        padding: const EdgeInsets.all(14),
        borderColor: selected ? method.color : AppColors.border,
        color: selected ? method.softColor : AppColors.white,
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: AppColors.softShadow,
              ),
              alignment: Alignment.center,
              child: Text(
                method.badge,
                style: AppText.label(
                  size: method == PaymentMethod.bkash ? 10 : 10.5,
                  color: method.color,
                  weight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(method.label,
                      style: AppText.body(
                          size: 14, weight: FontWeight.w700)),
                  Text(method.subtitle,
                      style: AppText.body(size: 11, color: AppColors.muted)),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              size: 20,
              color: selected ? method.color : AppColors.border,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pay() async {
    setState(() => _processing = true);
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    appState.pay(_method);
    if (!mounted) return;
    setState(() => _processing = false);
    Navigator.of(context).pushReplacement(
      riseRoute(const PaymentSuccessScreen()),
    );
  }
}

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final record = appState.currentBooking;
    final total = record?.total ?? appState.billTotal;
    final txn = record?.txn ?? txnId();
    final method = record?.method ?? PaymentMethod.cash;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(color: AppColors.cloud),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 260,
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.navyGradient,
                borderRadius: BorderRadius.vertical(
                    bottom: Radius.elliptical(420, 90)),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
              child: Column(
                children: [
                  ScaleTransition(
                    scale: const AlwaysStoppedAnimation<double>(1),
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: AppColors.tealGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.teal.withOpacity(0.4),
                            blurRadius: 30,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.check_rounded,
                          size: 44, color: AppColors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Payment successful',
                      style: AppText.display(26, color: AppColors.white)),
                  const SizedBox(height: 6),
                  Text(
                    'Paid ${money(total)} via ${method.label}',
                    style: AppText.body(
                        size: 13, color: AppColors.white.withOpacity(0.75)),
                  ),
                  const SizedBox(height: 30),
                  AppCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Icon(Icons.receipt_long_rounded,
                            size: 30, color: AppColors.teal),
                        const SizedBox(height: 10),
                        Text('Digital receipt', style: AppText.h2()),
                        const SizedBox(height: 4),
                        Text('Saved to your service history',
                            style: AppText.body(
                                size: 11.5, color: AppColors.muted)),
                        const SizedBox(height: 18),
                        _receiptRow('Transaction ID', txn),
                        _receiptRow('Service', record?.title ?? 'Vehicle service'),
                        _receiptRow('Vehicle', record?.vehicle ?? appState.selectedVehicle.name),
                        _receiptRow('Mechanic',
                            record?.mechanicName ?? appState.mechanic?.name ?? 'CarAid'),
                        _receiptRow('Services', money(appState.doneServicesTotal)),
                        _receiptRow('Travel', money(appState.travelFee)),
                        const Divider(height: 20),
                        _receiptRow('Total paid', money(total),
                            bold: true, color: AppColors.tealDark),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'Back to home',
                    icon: Icons.home_outlined,
                    onPressed: () =>
                        Navigator.of(context).popUntil((route) => route.isFirst),
                  ),
                  const SizedBox(height: 10),
                  SecondaryButton(
                    label: 'View service history',
                    icon: Icons.history_rounded,
                    onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                      riseRoute(const CustomerShell(initialTab: 2)),
                      (route) => false,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _receiptRow(String label, String value,
      {bool bold = false, Color color = AppColors.ink}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        children: [
          Text(label,
              style: AppText.body(size: 12, color: AppColors.muted)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: AppText.body(
                size: 12,
                weight: bold ? FontWeight.w800 : FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
