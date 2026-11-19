import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/geo.dart';
import '../../core/utils/ui.dart';
import '../../data/demo_data.dart';
import '../../models/service_entry.dart';
import '../../state/app_state.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import 'bill_screen.dart';

class ChecklistScreen extends StatefulWidget {
  /// 'mechanic' completes an incoming job; 'customer' reviews their own job.
  final String roleContext;

  const ChecklistScreen({super.key, this.roleContext = 'mechanic'});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  final List<BillLine> _lines = [];
  final _note = TextEditingController();
  late final int _travelFee;
  late final double _distanceKm;
  late final String _vehicle;
  late final String _counterpart;

  bool get _isMechanic => widget.roleContext == 'mechanic';

  @override
  void initState() {
    super.initState();
    final request = appState.activeRequest;
    if (_isMechanic && request != null) {
      _vehicle = request.vehicle;
      _counterpart = request.customerName;
      _distanceKm = request.distanceKm;
      _lines.addAll(_linesForRequest(request.problem));
      _travelFee = travelFeeFor(request.distanceKm);
    } else {
      _vehicle = appState.selectedVehicle.name;
      _counterpart = appState.mechanic?.name ?? 'Your mechanic';
      _distanceKm = appState.travelDistanceKm;
      _travelFee = appState.travelFee;
      if (appState.billLines.isEmpty) {
        final services = servicesForVehicle(appState.selectedVehicle.id)
            .where((s) => s.popular)
            .take(2)
            .toList();
        _lines.addAll(services.map((s) => BillLine(
              serviceId: s.id,
              name: s.name,
              amount: s.quote,
            )));
      } else {
        _lines.addAll(appState.billLines);
      }
    }
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  List<BillLine> _linesForRequest(String problem) {
    final lower = problem.toLowerCase();
    List<String> ids;
    if (lower.contains('brake')) {
      ids = ['car-brake', 'car-diagnostics'];
    } else if (lower.contains('chain')) {
      ids = ['bike-chain', 'bike-oil'];
    } else if (lower.contains('ac') || lower.contains('cool')) {
      ids = ['car-ac', 'car-diagnostics'];
    } else {
      ids = ['car-general', 'car-oil'];
    }
    return ids
        .map((id) => allServices.where((s) => s.id == id))
        .where((matches) => matches.isNotEmpty)
        .map((matches) {
          final service = matches.first;
          return BillLine(
            serviceId: service.id,
            name: service.name,
            amount: service.quote,
          );
        })
        .toList();
  }

  int get _servicesTotal => _lines
      .where((line) => line.done)
      .fold(0, (sum, line) => sum + line.amount);

  int get _total => _servicesTotal + _travelFee;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isMechanic ? 'Service checklist' : 'Review service'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              children: [
                AppCard(
                  padding: const EdgeInsets.all(16),
                  gradient: AppColors.navyGradient,
                  borderColor: Colors.transparent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isMechanic
                            ? 'Complete the job'
                            : 'Mechanic’s final checklist',
                        style: AppText.body(
                            size: 12, color: AppColors.white.withOpacity(0.7)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _vehicle,
                        style: AppText.display(24, color: AppColors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_isMechanic ? 'Customer' : 'Mechanic'}: $_counterpart',
                        style: AppText.body(
                            size: 12, color: AppColors.white.withOpacity(0.8)),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _smallStat(Icons.location_on_outlined,
                              distance(_distanceKm)),
                          const SizedBox(width: 10),
                          _smallStat(Icons.two_wheeler_rounded,
                              minutes(etaMinutesFor(_distanceKm))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: Text('Services performed', style: AppText.h3()),
                    ),
                    Text(
                      '${_lines.where((l) => l.done).length}/${_lines.length}',
                      style: AppText.label(size: 12, color: AppColors.teal),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _isMechanic
                      ? 'Tick everything you actually completed.'
                      : 'Confirm what the mechanic marked as done.',
                  style: AppText.body(size: 12, color: AppColors.muted),
                ),
                const SizedBox(height: 14),
                ..._lines.map((line) => _lineTile(line)),
                const SizedBox(height: 16),
                AppCard(
                  padding: const EdgeInsets.all(16),
                  color: AppColors.blue.withOpacity(0.04),
                  borderColor: AppColors.blue.withOpacity(0.18),
                  child: Row(
                    children: [
                      const IconTile(
                          icon: Icons.route_outlined, color: AppColors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Mechanic travel',
                                style: AppText.body(
                                    size: 13, weight: FontWeight.w700)),
                            Text(
                              'Base ৳60 + ৳18/km · ${distance(_distanceKm)}',
                              style: AppText.body(
                                  size: 11, color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                      Text(money(_travelFee),
                          style: AppText.price(size: 16)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text('Notes (optional)', style: AppText.label()),
                const SizedBox(height: 8),
                TextField(
                  controller: _note,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'E.g. replaced front brake pads, tyre pressure set',
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total bill',
                              style: AppText.body(
                                  size: 11.5, color: AppColors.muted)),
                          Text(money(_total),
                              style: AppText.display(24, color: AppColors.teal)),
                        ],
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 190,
                        child: PrimaryButton(
                          label: 'Generate bill',
                          icon: Icons.receipt_long_rounded,
                          onPressed: _lines.any((l) => l.done) ? _complete : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallStat(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.teal),
          const SizedBox(width: 5),
          Text(label,
              style: AppText.body(
                  size: 11.5, color: AppColors.white, weight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _lineTile(BillLine line) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        onTap: () => setState(() => line.done = !line.done),
        padding: const EdgeInsets.all(14),
        borderColor: line.done ? AppColors.teal : AppColors.border,
        color: line.done ? AppColors.teal.withOpacity(0.04) : AppColors.white,
        child: Row(
          children: [
            Icon(
              line.done
                  ? Icons.check_box_rounded
                  : Icons.check_box_outline_blank_rounded,
              color: line.done ? AppColors.teal : AppColors.faint,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(line.name,
                  style: AppText.body(
                      size: 13, weight: FontWeight.w600)),
            ),
            Text(money(line.amount), style: AppText.price(size: 15)),
          ],
        ),
      ),
    );
  }

  void _complete() {
    final checked = _lines.where((l) => l.done).toList();
    if (_isMechanic) {
      appState.completeMechanicJob(checked, _travelFee);
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: const Icon(Icons.check_circle_rounded,
              color: AppColors.teal, size: 38),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Job completed!', style: AppText.h2()),
              const SizedBox(height: 6),
              Text(
                '৳$_total has been added to your earnings, including ${money(_travelFee)} travel.',
                textAlign: TextAlign.center,
                style: AppText.body(
                    size: 12.5, color: AppColors.muted, height: 1.5),
              ),
            ],
          ),
          actions: [
            PrimaryButton(
              label: 'Done',
              expanded: false,
              height: 44,
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        ),
      );
    } else {
      appState.completeService(checked);
      Navigator.of(context)
          .pushReplacement(riseRoute(const BillScreen()));
    }
  }
}
