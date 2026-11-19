import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/geo.dart';
import '../../core/utils/ui.dart';
import '../../data/demo_data.dart';
import '../../models/mechanic_pro.dart';
import '../../models/service_entry.dart';
import '../../state/app_state.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/paywall_sheet.dart';
import '../shared/subscription_screen.dart';
import 'tracking_screen.dart';

class BookingScreen extends StatefulWidget {
  final String? initialServiceId;
  final String? vehicleId;
  final String? initialMechanicId;

  const BookingScreen({
    super.key,
    this.initialServiceId,
    this.vehicleId,
    this.initialMechanicId,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _step = 0;
  MechanicPro? _mechanic;

  @override
  void initState() {
    super.initState();
    if (widget.initialMechanicId != null) {
      final matches = demoMechanics
          .where((m) => m.id == widget.initialMechanicId)
          .toList();
      if (matches.isNotEmpty) {
        _mechanic = matches.first;
        _step = 2;
      }
    }
    if (widget.vehicleId != null) {
      final matches = vehicleTypes
          .where((v) => v.id == widget.vehicleId)
          .toList();
      if (matches.isNotEmpty) appState.chooseVehicle(matches.first);
    }
    if (widget.initialServiceId != null) {
      final matches = allServices
          .where((s) => s.id == widget.initialServiceId)
          .toList();
      if (matches.isNotEmpty && !appState.isServiceSelected(matches.first.id)) {
        appState.toggleService(matches.first.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(_step == 0
                ? 'Describe the problem'
                : _step == 1
                    ? 'Pick a mechanic'
                    : 'Review booking'),
            leading: IconButton(
              icon: Icon(_step == 0
                  ? Icons.close_rounded
                  : Icons.arrow_back_rounded),
              onPressed: () {
                if (_step == 0) {
                  Navigator.pop(context);
                } else {
                  setState(() => _step -= 1);
                }
              },
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(38),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: _StepIndicator(step: _step),
              ),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  child: _step == 0
                      ? _ProblemStep(key: const ValueKey(0))
                      : _step == 1
                          ? _MechanicStep(
                              key: const ValueKey(1),
                              selected: _mechanic,
                              onSelect: (m) => setState(() => _mechanic = m),
                            )
                          : _ReviewStep(
                              key: const ValueKey(2),
                              mechanic: _mechanic!,
                            ),
                ),
              ),
              _footer(context),
            ],
          ),
        );
      },
    );
  }

  Widget _footer(BuildContext context) {
    final serviceCount = appState.selectedServices.length;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 14, 20, MediaQuery.of(context).padding.bottom + 16),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_step == 2 && !appState.hasAccess)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline_rounded,
                        size: 14, color: AppColors.amber),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Premium unlocks live tracking & chat.',
                        style: AppText.body(
                            size: 11.5, color: AppColors.muted),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context)
                          .push(riseRoute(const SubscriptionScreen())),
                      child: Text(
                        'See plans',
                        style: AppText.label(
                            size: 11.5,
                            color: AppColors.teal,
                            weight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            PrimaryButton(
              label: _step == 0
                  ? 'Choose mechanic${serviceCount > 0 ? ' ($serviceCount)' : ''}'
                  : _step == 1
                      ? 'Review booking'
                      : 'Confirm & track',
              icon: _step == 2 ? Icons.near_me_rounded : null,
              onPressed: _step == 2
                  ? _confirm
                  : () {
                      if (_step == 0 && serviceCount == 0) {
                        showAppSnack(
                          context,
                          'Select at least one service.',
                          error: true,
                        );
                        return;
                      }
                      if (_step == 1 && _mechanic == null) {
                        showAppSnack(
                          context,
                          'Choose a mechanic to continue.',
                          error: true,
                        );
                        return;
                      }
                      setState(() => _step += 1);
                    },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirm() async {
    if (_mechanic == null) return;
    final allowed = await ensureAccess(context);
    if (!allowed || !mounted) return;

    appState.startBooking(_mechanic!);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
        riseRoute(const TrackingScreen(freshBooking: true)));
  }
}

class _StepIndicator extends StatelessWidget {
  final int step;

  const _StepIndicator({required this.step});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (index) {
        final active = index <= step;
        return Expanded(
          child: Container(
            height: 5,
            margin: EdgeInsets.only(right: index == 2 ? 0 : 6),
            decoration: BoxDecoration(
              color: active ? AppColors.teal : AppColors.border,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      }),
    );
  }
}

class _ProblemStep extends StatelessWidget {
  const _ProblemStep({super.key});

  @override
  Widget build(BuildContext context) {
    final services = servicesForVehicle(appState.selectedVehicle.id);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      children: [
        Text('Select your vehicle', style: AppText.h3()),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: vehicleTypes.map((v) {
            return AppPill(
              label: v.name,
              icon: v.icon,
              selected: v.id == appState.selectedVehicle.id,
              onTap: () => appState.chooseVehicle(v),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
                child: Text('What is the problem?', style: AppText.h3())),
            Text(
              '${appState.selectedServices.length} selected',
              style: AppText.label(size: 11, color: AppColors.teal),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Pick one or more services. Prices are transparent.',
          style: AppText.body(size: 12, color: AppColors.muted),
        ),
        const SizedBox(height: 14),
        ...services.map((service) => _ServiceTile(service: service)),
      ],
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final ServiceEntry service;

  const _ServiceTile({required this.service});

  @override
  Widget build(BuildContext context) {
    final selected = appState.isServiceSelected(service.id);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        onTap: () => appState.toggleService(service.id),
        padding: const EdgeInsets.all(14),
        borderColor: selected ? AppColors.teal : AppColors.border,
        color: selected ? AppColors.teal.withOpacity(0.04) : AppColors.white,
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: selected ? AppColors.teal : AppColors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selected ? AppColors.teal : AppColors.border,
                  width: selected ? 1 : 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: selected
                  ? const Icon(Icons.check_rounded,
                      size: 16, color: AppColors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service.name,
                      style: AppText.body(
                          size: 13, weight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(service.note,
                      style: AppText.body(size: 11, color: AppColors.muted)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(service.rangeLabel,
                          style: AppText.price(
                              size: 13, color: AppColors.tealDark)),
                      const SizedBox(width: 10),
                      Icon(Icons.schedule_rounded,
                          size: 12, color: AppColors.faint),
                      Text(' ${service.durationMins} min',
                          style: AppText.body(
                              size: 10.5, color: AppColors.faint)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MechanicStep extends StatelessWidget {
  final MechanicPro? selected;
  final ValueChanged<MechanicPro> onSelect;

  const _MechanicStep({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final mechanics = List<MechanicPro>.from(demoMechanics)
      ..sort((a, b) => a.baseDistanceKm.compareTo(b.baseDistanceKm));

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Available near you',
                style: AppText.h3(),
              ),
            ),
            const StatusPill(
                label: 'SORTED BY DISTANCE',
                color: AppColors.blue,
                icon: Icons.sort_rounded),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Live GPS tracking starts as soon as they accept.',
          style: AppText.body(size: 12, color: AppColors.muted),
        ),
        const SizedBox(height: 14),
        ...mechanics.map((mechanic) {
          final isSelected = selected?.id == mechanic.id;
          final distance = math.max(
            0.6,
            haversineKm(
              appState.customerLat,
              appState.customerLng,
              mechanic.lat,
              mechanic.lng,
            ),
          );
          return AppCard(
            onTap: () => onSelect(mechanic),
            padding: const EdgeInsets.all(14),
            borderColor: isSelected ? AppColors.teal : AppColors.border,
            color:
                isSelected ? AppColors.teal.withOpacity(0.04) : AppColors.white,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.tealSoft,
                  child: Text(
                    initials(mechanic.name),
                    style: AppText.label(
                        size: 12,
                        color: AppColors.tealDark,
                        weight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(mechanic.name,
                                style: AppText.body(
                                    size: 13, weight: FontWeight.w700)),
                          ),
                          const Icon(Icons.star_rounded,
                              size: 13, color: AppColors.amber),
                          Text(' ${mechanic.rating}',
                              style: AppText.body(
                                  size: 11, weight: FontWeight.w700)),
                        ],
                      ),
                      Text(mechanic.garage,
                          style:
                              AppText.body(size: 11, color: AppColors.muted)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          StatusPill(
                            label: mechanic.isOnline ? 'Available' : 'Busy',
                            color: mechanic.isOnline
                                ? AppColors.teal
                                : AppColors.faint,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${distance.toStringAsFixed(1)} km · ${etaMinutesFor(distance)} min',
                            style: AppText.body(
                                size: 10.5, color: AppColors.faint),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: isSelected ? AppColors.teal : AppColors.border,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

}

class _ReviewStep extends StatelessWidget {
  final MechanicPro mechanic;

  const _ReviewStep({super.key, required this.mechanic});

  @override
  Widget build(BuildContext context) {
    final distance = math.max(
      0.6,
      haversineKm(
        appState.customerLat,
        appState.customerLng,
        mechanic.lat,
        mechanic.lng,
      ),
    );
    final serviceTotal = appState.servicesEstimate;
    final travel = travelFeeFor(distance);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      children: [
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.tealSoft,
                child: Text(
                  initials(mechanic.name),
                  style: AppText.label(
                      size: 13,
                      color: AppColors.tealDark,
                      weight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mechanic.name,
                        style: AppText.body(
                            size: 14, weight: FontWeight.w700)),
                    Text('${mechanic.garage} · ${mechanic.experienceLabel}',
                        style:
                            AppText.body(size: 11.5, color: AppColors.muted)),
                  ],
                ),
              ),
              const Icon(Icons.verified_rounded,
                  color: AppColors.teal, size: 20),
            ],
          ),
        ),
        const SizedBox(height: 14),
        AppCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your request', style: AppText.h3()),
              const SizedBox(height: 12),
              _summaryRow(Icons.directions_car_outlined, 'Vehicle',
                  appState.selectedVehicle.name),
              _summaryRow(Icons.build_outlined, 'Services',
                  '${appState.selectedServices.length} selected'),
              const SizedBox(height: 8),
              ...appState.selectedServices.map((service) => Padding(
                    padding: const EdgeInsets.only(left: 30, bottom: 5),
                    child: Row(
                      children: [
                        const Icon(Icons.check_rounded,
                            size: 14, color: AppColors.teal),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(service.name,
                              style: AppText.body(
                                  size: 11.5, color: AppColors.muted)),
                        ),
                        Text(service.quote > 0 ? money(service.quote) : '',
                            style: AppText.body(
                                size: 11, color: AppColors.muted)),
                      ],
                    ),
                  )),
              const Divider(height: 22),
              _summaryRow(Icons.location_on_outlined, 'Distance',
                  '${distance.toStringAsFixed(1)} km'),
              _summaryRow(Icons.schedule_rounded, 'Estimated arrival',
                  minutes(etaMinutesFor(distance))),
            ],
          ),
        ),
        const SizedBox(height: 14),
        AppCard(
          padding: const EdgeInsets.all(18),
          color: AppColors.teal.withOpacity(0.05),
          borderColor: AppColors.teal.withOpacity(0.25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Estimated cost', style: AppText.body(weight: FontWeight.w700)),
              const SizedBox(height: 12),
              _costRow('Services', money(serviceTotal)),
              const SizedBox(height: 8),
              _costRow('Mechanic travel', money(travel)),
              const SizedBox(height: 8),
              _costRow('Platform fee', '৳0', color: AppColors.teal),
              const Divider(height: 20),
              Row(
                children: [
                  Text('Estimated total', style: AppText.body(size: 13.5)),
                  const Spacer(),
                  Text(money(serviceTotal + travel),
                      style: AppText.display(24, color: AppColors.tealDark)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'The mechanic confirms the final checklist after inspection. Travel is added automatically.',
                style: AppText.body(size: 11, color: AppColors.muted, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.teal),
          const SizedBox(width: 10),
          Text(label, style: AppText.body(size: 12, color: AppColors.muted)),
          const Spacer(),
          Text(value, style: AppText.body(size: 12, weight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _costRow(String label, String value, {Color color = AppColors.ink}) {
    return Row(
      children: [
        Text(label, style: AppText.body(size: 12.5, color: AppColors.muted)),
        const Spacer(),
        Text(value,
            style: AppText.body(size: 12.5, weight: FontWeight.w700, color: color)),
      ],
    );
  }
}
