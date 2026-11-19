import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/geo.dart';
import '../../data/demo_data.dart';
import '../../models/service_entry.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';

class CostEstimatorScreen extends StatefulWidget {
  const CostEstimatorScreen({super.key});

  @override
  State<CostEstimatorScreen> createState() => _CostEstimatorScreenState();
}

class _CostEstimatorScreenState extends State<CostEstimatorScreen> {
  String _vehicleId = 'car';
  String? _serviceId;
  double _distanceKm = 4;

  List<ServiceEntry> get _services => servicesForVehicle(_vehicleId);

  ServiceEntry? get _service {
    final match = _services.where((s) => s.id == _serviceId).toList();
    return match.isEmpty ? null : match.first;
  }

  int get _serviceCost => _service?.quote ?? 0;
  int get _travelCost => travelFeeFor(_distanceKm);
  int get _total => _serviceCost + _travelCost;

  @override
  Widget build(BuildContext context) {
    final service = _service;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Repair cost estimator'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
        children: [
          AppCard(
            padding: const EdgeInsets.all(16),
            color: AppColors.teal.withOpacity(0.06),
            borderColor: AppColors.teal.withOpacity(0.22),
            child: Row(
              children: [
                const IconTile(icon: Icons.calculate_rounded),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Know before you go',
                          style: AppText.body(
                              size: 13.5, weight: FontWeight.w700)),
                      Text('Instant BDT estimate · completely free',
                          style: AppText.body(
                              size: 11.5, color: AppColors.muted)),
                    ],
                  ),
                ),
                const StatusPill(
                    label: 'FREE',
                    color: AppColors.teal,
                    icon: Icons.lock_open_rounded),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text('1. Choose your vehicle', style: AppText.h3()),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: vehicleTypes.map((vehicle) {
              final active = vehicle.id == _vehicleId;
              return AppPill(
                label: vehicle.name,
                icon: vehicle.icon,
                selected: active,
                onTap: () => setState(() {
                  _vehicleId = vehicle.id;
                  _serviceId = null;
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: 22),
          Text('2. Select a service', style: AppText.h3()),
          const SizedBox(height: 10),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _serviceId,
                hint: Text(
                  'Pick a service (${_services.length} available)',
                  style: AppText.body(size: 13, color: AppColors.muted),
                ),
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: AppColors.teal),
                items: _services
                    .map(
                      (s) => DropdownMenuItem<String>(
                        value: s.id,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                s.name,
                                style: AppText.body(size: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(s.rangeLabel,
                                style: AppText.body(
                                    size: 11, color: AppColors.tealDark)),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _serviceId = value),
              ),
            ),
          ),
          if (service != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                service.note,
                style: AppText.body(size: 11.5, color: AppColors.muted),
              ),
            ),
          ],
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(child: Text('3. Travel distance', style: AppText.h3())),
              Text(distance(_distanceKm),
                  style: AppText.body(
                      size: 13, weight: FontWeight.w700, color: AppColors.teal)),
            ],
          ),
          const SizedBox(height: 6),
          Slider(
            value: _distanceKm,
            min: 0.5,
            max: 20,
            divisions: 39,
            label: distance(_distanceKm),
            onChanged: (value) => setState(() => _distanceKm = value),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0.5 km', style: AppText.body(size: 10.5, color: AppColors.faint)),
              Text('20 km', style: AppText.body(size: 10.5, color: AppColors.faint)),
            ],
          ),
          const SizedBox(height: 22),
          AppCard(
            padding: const EdgeInsets.all(20),
            gradient: AppColors.navyGradient,
            borderColor: Colors.transparent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Estimated total',
                    style: AppText.body(
                        size: 12, color: AppColors.white.withOpacity(0.7))),
                const SizedBox(height: 4),
                Text(
                  service == null ? 'Select a service' : money(_total),
                  style: AppText.display(
                    service == null ? 24 : 36,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white24),
                const SizedBox(height: 12),
                _breakdown('Service charge',
                    service == null ? '—' : money(_serviceCost)),
                const SizedBox(height: 8),
                _breakdown(
                  'Mechanic travel (৳60 + ৳18/km)',
                  money(_travelCost),
                ),
                const SizedBox(height: 8),
                _breakdown('Platform fee', '৳0', color: AppColors.teal),
                if (service != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    'Expected duration: ${minutes(service.durationMins)} · Price range ${service.rangeLabel}',
                    style: AppText.body(
                      size: 11,
                      color: AppColors.white.withOpacity(0.65),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Estimate only. The final bill is prepared by the mechanic after inspection and includes the actual travel distance.',
            style: AppText.body(
              size: 11,
              color: AppColors.faint,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _breakdown(String label, String value, {Color color = Colors.white}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppText.body(
                size: 12, color: AppColors.white.withOpacity(0.72)),
          ),
        ),
        Text(value,
            style: AppText.body(
                size: 12.5, weight: FontWeight.w700, color: color)),
      ],
    );
  }
}
