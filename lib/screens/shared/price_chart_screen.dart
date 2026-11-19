import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/ui.dart';
import '../../data/demo_data.dart';
import '../../models/service_entry.dart';
import '../../widgets/app_card.dart';

class PriceChartScreen extends StatefulWidget {
  const PriceChartScreen({super.key});

  @override
  State<PriceChartScreen> createState() => _PriceChartScreenState();
}

class _PriceChartScreenState extends State<PriceChartScreen> {
  final _search = TextEditingController();
  String _vehicleId = 'all';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();
    final results = allServices.where((service) {
      final vehicleMatch = _vehicleId == 'all' || service.vehicleId == _vehicleId;
      final searchMatch = query.isEmpty ||
          service.name.toLowerCase().contains(query) ||
          service.note.toLowerCase().contains(query);
      return vehicleMatch && searchMatch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Service price chart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => showAppSnack(
              context,
              'Indicative 2026 Dhaka prices. Final quote after inspection.',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Search a service, e.g. brake, oil',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: vehicleTypes.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final id = index == 0 ? 'all' : vehicleTypes[index - 1].id;
                final label = index == 0 ? 'All' : vehicleTypes[index - 1].name;
                final active = id == _vehicleId;
                return GestureDetector(
                  onTap: () => setState(() => _vehicleId = id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 9),
                    decoration: BoxDecoration(
                      color: active ? AppColors.teal : AppColors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                          color: active ? AppColors.teal : AppColors.border),
                    ),
                    child: Text(
                      label,
                      style: AppText.label(
                        size: 12.5,
                        color: active ? AppColors.white : AppColors.muted,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.search_off_rounded,
                            size: 42, color: AppColors.faint),
                        const SizedBox(height: 12),
                        Text('No prices found', style: AppText.h3()),
                        const SizedBox(height: 4),
                        Text(
                          'Try a different keyword or vehicle.',
                          style: AppText.body(
                              size: 12, color: AppColors.muted),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 2, 20, 30),
                    itemCount: results.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) return const _FreeBanner();
                      final service = results[index - 1];
                      return _PriceRow(service: service);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FreeBanner extends StatelessWidget {
  const _FreeBanner();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 14),
      color: AppColors.teal.withOpacity(0.06),
      borderColor: AppColors.teal.withOpacity(0.22),
      child: Row(
        children: [
          const IconTile(icon: Icons.lock_open_rounded),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Always free, always transparent',
                    style: AppText.body(size: 13.5, weight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  'Know the fair price before you book. No subscription needed.',
                  style: AppText.body(size: 11.5, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final ServiceEntry service;

  const _PriceRow({required this.service});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.cloud,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(
              _vehicleIcon(service.vehicleId),
              size: 20,
              color: AppColors.muted,
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
                      child: Text(
                        service.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.body(
                            size: 13, weight: FontWeight.w700),
                      ),
                    ),
                    if (service.popular)
                      const StatusPill(
                        label: 'POPULAR',
                        color: AppColors.amber,
                        icon: Icons.star_rounded,
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(service.note,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body(size: 11, color: AppColors.muted)),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Text(service.rangeLabel,
                        style: AppText.price(
                            size: 14, color: AppColors.tealDark)),
                    const Spacer(),
                    Icon(Icons.schedule_rounded,
                        size: 12, color: AppColors.faint),
                    const SizedBox(width: 3),
                    Text(minutes(service.durationMins),
                        style: AppText.body(
                            size: 10.5, color: AppColors.faint)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _vehicleIcon(String id) {
    switch (id) {
      case 'bike':
        return Icons.two_wheeler_rounded;
      case 'cng':
        return Icons.electric_rickshaw_rounded;
      case 'truck':
        return Icons.local_shipping_rounded;
      default:
        return Icons.directions_car_rounded;
    }
  }
}
