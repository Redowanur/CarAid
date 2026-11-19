import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/geo.dart';
import '../../core/utils/ui.dart';
import '../../data/demo_data.dart';
import '../../models/mechanic_pro.dart';
import '../../state/app_state.dart';
import '../../widgets/app_card.dart';
import '../shared/mechanic_detail_screen.dart';

class MechanicsTab extends StatefulWidget {
  const MechanicsTab({super.key});

  @override
  State<MechanicsTab> createState() => _MechanicsTabState();
}

class _MechanicsTabState extends State<MechanicsTab> {
  final _search = TextEditingController();
  String _filter = 'All';
  static const _filters = ['All', 'Car', 'Bike', 'Tyres', 'AC'];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final query = _search.text.trim().toLowerCase();
        var mechanics = List<MechanicPro>.from(demoMechanics);
        if (query.isNotEmpty) {
          mechanics = mechanics
              .where((m) =>
                  m.name.toLowerCase().contains(query) ||
                  m.garage.toLowerCase().contains(query) ||
                  m.specialties
                      .any((s) => s.toLowerCase().contains(query)))
              .toList();
        }
        if (_filter != 'All') {
          mechanics = mechanics
              .where((m) => m.specialties.any(
                    (s) => s.toLowerCase().contains(_filter.toLowerCase()),
                  ))
              .toList();
        }
        mechanics.sort((a, b) => a.baseDistanceKm.compareTo(b.baseDistanceKm));

        return Scaffold(
          appBar: AppBar(
            title: const Text('Mechanics near you'),
            actions: [
              IconButton(
                icon: const Icon(Icons.my_location_rounded),
                onPressed: () async {
                  final found = await appState.refreshLocation();
                  if (context.mounted) {
                    showAppSnack(
                      context,
                      found ? 'Location updated' : 'Using demo location',
                    );
                  }
                },
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
                    hintText: 'Search name, garage or specialty',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
              ),
              SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final active = filter == _filter;
                    return GestureDetector(
                      onTap: () => setState(() => _filter = filter),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: active ? AppColors.teal : AppColors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: active ? AppColors.teal : AppColors.border,
                          ),
                        ),
                        child: Text(
                          filter,
                          style: AppText.label(
                            size: 12,
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
                child: mechanics.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.search_off_rounded,
                                size: 40, color: AppColors.faint),
                            const SizedBox(height: 12),
                            Text('No mechanics found', style: AppText.h3()),
                            const SizedBox(height: 4),
                            Text(
                              'Try another name or specialty.',
                              style: AppText.body(
                                  size: 12, color: AppColors.muted),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 6, 20, 110),
                        itemCount: mechanics.length,
                        itemBuilder: (context, index) =>
                            _MechanicCard(mechanic: mechanics[index]),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MechanicCard extends StatelessWidget {
  final MechanicPro mechanic;

  const _MechanicCard({required this.mechanic});

  @override
  Widget build(BuildContext context) {
    final distanceKm = math.max(
      0.6,
      haversineKm(appState.customerLat, appState.customerLng,
          mechanic.lat, mechanic.lng),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        onTap: () => Navigator.of(context)
            .push(riseRoute(MechanicDetailScreen(mechanic: mechanic))),
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.tealSoft,
                  child: Text(
                    initials(mechanic.name),
                    style: AppText.label(
                      size: 14,
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
                      Text(mechanic.name,
                          style: AppText.body(
                              size: 14, weight: FontWeight.w700)),
                      Text(mechanic.garage,
                          style: AppText.body(
                              size: 11.5, color: AppColors.muted)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 13, color: AppColors.amber),
                          Text(' ${mechanic.rating} (${mechanic.reviews})',
                              style: AppText.body(
                                  size: 10.5, color: AppColors.muted)),
                          const SizedBox(width: 10),
                          Text(mechanic.experienceLabel,
                              style: AppText.body(
                                  size: 10.5, color: AppColors.faint)),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    StatusPill(
                      label: mechanic.isOnline ? 'Online' : 'Busy',
                      color:
                          mechanic.isOnline ? AppColors.teal : AppColors.faint,
                    ),
                    const SizedBox(height: 6),
                    Text(distance(distanceKm),
                        style: AppText.body(
                            size: 11.5, weight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: mechanic.specialties
                  .map(
                    (s) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.cloud,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        s,
                        style: AppText.body(size: 10, color: AppColors.muted),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
