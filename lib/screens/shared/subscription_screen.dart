import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/ui.dart';
import '../../data/demo_data.dart';
import '../../models/booking.dart';
import '../../models/payment_method.dart';
import '../../models/vehicle_type.dart';
import '../../state/app_state.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool yearly = true;

  @override
  Widget build(BuildContext context) {
    final role = appState.role ?? UserRole.customer;
    final plans = plansForRole(role);
    final selected = yearly
        ? plans.firstWhere((p) => p.months == 12, orElse: () => plans.last)
        : plans.firstWhere((p) => p.months == 1, orElse: () => plans.first);
    final isMechanic = role == UserRole.mechanic;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CarAid Premium'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, _) {
          final hasAccess = appState.hasAccess;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 36),
            children: [
              _heroCard(isMechanic, hasAccess),
              if (!hasAccess) ...[
                const SizedBox(height: 16),
                _trialCard(),
              ],
              const SizedBox(height: 22),
              _billingToggle(),
              const SizedBox(height: 16),
              ...plans.map((plan) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _planCard(
                      plan,
                      selected: selected.id == plan.id,
                      onTap: () => setState(() {
                        yearly = plan.months == 12;
                      }),
                    ),
                  )),
              const SizedBox(height: 6),
              PrimaryButton(
                label: hasAccess
                    ? 'Extend plan · ${selected.priceLabel}${selected.period}'
                    : 'Continue · ${selected.priceLabel}${selected.period}',
                icon: Icons.lock_open_rounded,
                onPressed: () => _openCheckout(selected),
              ),
              const SizedBox(height: 26),
              Text('What you unlock', style: AppText.h3()),
              const SizedBox(height: 12),
              ...premiumFeatures.map((feature) => _featureRow(
                    feature,
                    Icons.check_circle_rounded,
                    AppColors.teal,
                  )),
              const SizedBox(height: 22),
              Text('Always free', style: AppText.h3()),
              const SizedBox(height: 4),
              Text(
                'No subscription needed for these.',
                style: AppText.body(color: AppColors.muted, size: 12.5),
              ),
              const SizedBox(height: 12),
              ...freeFeatures.map((feature) => _featureRow(
                    feature,
                    Icons.lock_open_rounded,
                    AppColors.blue,
                  )),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.blueSoft,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: AppColors.blue, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Demo billing is simulated. bKash, Nagad and Rocket checkouts do not charge real money.',
                        style: AppText.body(
                            size: 12, color: AppColors.blue, height: 1.45),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _heroCard(bool isMechanic, bool hasAccess) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.premiumGradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: AppColors.liftShadow,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.amber.withOpacity(0.18),
              ),
            ),
          ),
          Column(
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
                        color: AppColors.amber, size: 22),
                  ),
                  const SizedBox(width: 10),
                  StatusPill(
                    label: hasAccess ? appState.accessLabel : 'Free plan',
                    color: hasAccess ? AppColors.teal : AppColors.amber,
                    icon: hasAccess
                        ? Icons.verified_rounded
                        : Icons.lock_outline_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                isMechanic
                    ? 'Grow your garage.\nGet more jobs.'
                    : 'Your car, covered.\nAnytime, anywhere.',
                style: AppText.display(26, color: AppColors.white),
              ),
              const SizedBox(height: 10),
              Text(
                isMechanic
                    ? 'Unlimited requests, priority placement and instant digital billing for your workshop.'
                    : 'Live tracking, chat, calls and cashless payment with verified mechanics near you.',
                style: AppText.body(
                  color: AppColors.white.withOpacity(0.72),
                  size: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _trialCard() {
    return AppCard(
      padding: const EdgeInsets.all(16),
      borderColor: AppColors.teal.withOpacity(0.3),
      child: Row(
        children: [
          const IconTile(icon: Icons.timer_rounded, color: AppColors.teal),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('7 days free, cancel anytime',
                    style: AppText.body(weight: FontWeight.w700, size: 13.5)),
                const SizedBox(height: 2),
                Text('Try every premium feature before paying.',
                    style: AppText.body(
                        size: 12, color: AppColors.muted, height: 1.4)),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              appState.startTrial();
              showAppSnack(context, 'Your 7-day free trial has started.');
            },
            child: Text(
              'Start',
              style: AppText.label(
                  size: 13, color: AppColors.teal, weight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _billingToggle() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _toggleItem('Monthly', !yearly, () => setState(() => yearly = false)),
          _toggleItem('Yearly · save 16%', yearly,
              () => setState(() => yearly = true)),
        ],
      ),
    );
  }

  Widget _toggleItem(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 11),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? AppColors.ink : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: AppText.body(
              size: 12.5,
              weight: FontWeight.w700,
              color: active ? AppColors.white : AppColors.muted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _planCard(SubscriptionPlan plan, {required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? AppColors.teal : AppColors.border,
            width: selected ? 1.8 : 1,
          ),
          boxShadow: selected ? AppColors.softShadow : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? AppColors.teal : AppColors.border,
                      width: 2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: selected ? 11 : 0,
                    height: selected ? 11 : 0,
                    decoration: const BoxDecoration(
                      color: AppColors.teal,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(plan.name,
                      style: AppText.body(
                          size: 14.5, weight: FontWeight.w700)),
                ),
                if (plan.popular)
                  const StatusPill(
                    label: 'BEST VALUE',
                    color: AppColors.amber,
                    icon: Icons.star_rounded,
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(plan.priceLabel, style: AppText.display(28)),
                Text(plan.period,
                    style: AppText.body(color: AppColors.muted, size: 13)),
                const Spacer(),
                if (plan.months == 12)
                  Text('৳${(plan.price / 12).round()} /mo',
                      style: AppText.body(
                          color: AppColors.muted, size: 12)),
              ],
            ),
            const SizedBox(height: 12),
            ...plan.perks.map((perk) => Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Row(
                    children: [
                      const Icon(Icons.check_rounded,
                          size: 15, color: AppColors.teal),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(perk,
                            style: AppText.body(
                                size: 12.5, color: AppColors.muted)),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _featureRow(String label, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: AppText.body(size: 13.5))),
        ],
      ),
    );
  }

  Future<void> _openCheckout(SubscriptionPlan plan) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CheckoutSheet(plan: plan),
    );
    if (result == true && mounted) {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => _SuccessDialog(
          plan: plan,
          onDone: () {
            Navigator.pop(dialogContext);
            Navigator.pop(context, true);
          },
        ),
      );
    }
  }
}

class _CheckoutSheet extends StatefulWidget {
  final SubscriptionPlan plan;

  const _CheckoutSheet({required this.plan});

  @override
  State<_CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends State<_CheckoutSheet> {
  PaymentMethod method = PaymentMethod.bkash;
  bool processing = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 26),
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
          const SizedBox(height: 22),
          Text('Checkout', style: AppText.h2()),
          const SizedBox(height: 4),
          Text('${widget.plan.name} · ${widget.plan.priceLabel}${widget.plan.period}',
              style: AppText.body(color: AppColors.muted, size: 13)),
          const SizedBox(height: 18),
          ...paymentMethods.map((m) => _methodTile(m)),
          const SizedBox(height: 12),
          PrimaryButton(
            label: 'Pay ${widget.plan.priceLabel}',
            loading: processing,
            onPressed: () async {
              setState(() => processing = true);
              await Future<void>.delayed(const Duration(milliseconds: 1400));
              await appState.purchasePlan(widget.plan);
              if (mounted) Navigator.pop(context, true);
            },
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              'Simulated payment · no real charge',
              style: AppText.body(size: 11.5, color: AppColors.faint),
            ),
          ),
        ],
      ),
    );
  }

  Widget _methodTile(PaymentMethod m) {
    final selected = method == m;
    return GestureDetector(
      onTap: () => setState(() => method = m),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? m.softColor : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? m.color : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: m.softColor,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                m.badge,
                style: AppText.label(
                  size: 10.5,
                  color: m.color,
                  weight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m.label,
                      style: AppText.body(
                          size: 13.5, weight: FontWeight.w700)),
                  Text(m.subtitle,
                      style: AppText.body(size: 11, color: AppColors.muted)),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? m.color : AppColors.border,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessDialog extends StatelessWidget {
  final SubscriptionPlan plan;
  final VoidCallback onDone;

  const _SuccessDialog({required this.plan, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.tealGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.workspace_premium_rounded,
                  color: AppColors.white, size: 34),
            ),
            const SizedBox(height: 18),
            Text('You are Premium!', style: AppText.h2()),
            const SizedBox(height: 8),
            Text(
              '${plan.name} is active. Live tracking, chat, calls and cashless payment are unlocked.',
              textAlign: TextAlign.center,
              style: AppText.body(color: AppColors.muted, height: 1.5),
            ),
            const SizedBox(height: 20),
            PrimaryButton(label: 'Let\'s go', onPressed: onDone),
          ],
        ),
      ),
    );
  }
}
