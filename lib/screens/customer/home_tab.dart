import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/ui.dart';
import '../../data/demo_data.dart';
import '../../models/booking.dart';
import '../../models/mechanic_pro.dart';
import '../../state/app_state.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/paywall_sheet.dart';
import '../shared/cost_estimator_screen.dart';
import '../shared/maintenance_tips_screen.dart';
import '../shared/mechanic_detail_screen.dart';
import '../shared/price_chart_screen.dart';
import '../shared/subscription_screen.dart';
import 'booking_screen.dart';
import 'tracking_screen.dart';

class HomeTab extends StatelessWidget {
  final VoidCallback? onOpenMechanics;

  const HomeTab({super.key, this.onOpenMechanics});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final mechanics = List<MechanicPro>.from(demoMechanics)
          ..sort((a, b) => a.baseDistanceKm.compareTo(b.baseDistanceKm));

        return ListView(
          key: const PageStorageKey('customer-home'),
          padding: const EdgeInsets.only(bottom: 110),
          children: [
            _Header(greeting: greeting(DateTime.now())),
            Transform.translate(
              offset: const Offset(0, -52),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RequestCard(),
                    if (_hasOngoingJob()) ...[
                      const SizedBox(height: 14),
                      _OngoingJobCard(),
                    ],
                    if (!appState.customerHasAccess) ...[
                      const SizedBox(height: 16),
                      PremiumBanner(
                        title: 'Track your mechanic live',
                        subtitle:
                            'Chat, call and pay cashless with CarAid Premium.',
                        onTap: () => Navigator.of(context)
                            .push(riseRoute(const SubscriptionScreen())),
                      ),
                    ],
                    const SectionHeader(
                      title: 'Free tools',
                      actionLabel: null,
                      padding: EdgeInsets.fromLTRB(2, 24, 2, 10),
                    ),
                    _FreeTools(),
                    SectionHeader(
                      title: 'Popular fixes',
                      actionLabel: 'See all prices',
                      padding: const EdgeInsets.fromLTRB(2, 24, 2, 10),
                      onAction: () => Navigator.of(context)
                          .push(riseRoute(const PriceChartScreen())),
                    ),
                    _PopularServices(),
                    SectionHeader(
                      title: 'Mechanics near you',
                      actionLabel: 'View all',
                      padding: const EdgeInsets.fromLTRB(2, 24, 2, 10),
                      onAction: () => onOpenMechanics?.call(),
                    ),
                    SizedBox(
                      height: 172,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.none,
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        itemCount: mechanics.take(5).length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) =>
                            _NearbyMechanicCard(mechanic: mechanics[index]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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

class _Header extends StatelessWidget {
  final String greeting;

  const _Header({required this.greeting});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.navyGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(34)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 22, 20, 70),
      child: Stack(
        children: [
          Positioned(
            right: 32,
            top: 4,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.teal.withOpacity(0.10),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CarAidLogo(size: 36, light: true),
                  const Spacer(),
                  CircleIconButton(
                    icon: Icons.notifications_none_rounded,
                    size: 40,
                    background: AppColors.white.withOpacity(0.12),
                    foreground: AppColors.white,
                    onPressed: () =>
                        showAppSnack(context, 'No new notifications.'),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                '$greeting, ${appState.firstName}!',
                style: AppText.display(26, color: AppColors.white),
              ),
              const SizedBox(height: 6),
              Text(
                'Your ride deserves the best care.',
                style: AppText.body(
                  color: AppColors.white.withOpacity(0.65),
                  size: 13,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Icon(Icons.my_location_rounded,
                      size: 16, color: AppColors.teal),
                  const SizedBox(width: 6),
                  Text(
                    appState.isLocating
                        ? 'Finding your location...'
                        : 'Gulshan 2, Dhaka',
                    style: AppText.body(
                        color: AppColors.white.withOpacity(0.85), size: 12.5),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () async {
                      final found = await appState.refreshLocation();
                      if (context.mounted) {
                        showAppSnack(
                          context,
                          found
                              ? 'Location updated'
                              : 'Using demo location in Dhaka',
                        );
                      }
                    },
                    child: const Icon(Icons.refresh_rounded,
                        size: 15, color: AppColors.faint),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const IconTile(icon: Icons.car_repair_rounded),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('What needs fixing?', style: AppText.h3()),
                    Text(
                      'Choose your vehicle and tell us the problem.',
                      style: AppText.body(size: 11.5, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              const StatusPill(
                label: 'ON-DEMAND',
                color: AppColors.amber,
                icon: Icons.bolt_rounded,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: vehicleTypes.map((vehicle) {
              final selected = appState.selectedVehicle.id == vehicle.id;
              return AppPill(
                label: vehicle.name,
                icon: vehicle.icon,
                selected: selected,
                onTap: () => appState.chooseVehicle(vehicle),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          if (appState.selectedServices.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.tealSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      size: 16, color: AppColors.tealDark),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${appState.selectedServices.length} service(s) selected · est. ${money(appState.servicesEstimate)}',
                      style: AppText.body(
                          size: 12,
                          weight: FontWeight.w600,
                          color: AppColors.tealDark),
                    ),
                  ),
                ],
              ),
            ),
          PrimaryButton(
            label: 'Find a mechanic',
            icon: Icons.near_me_rounded,
            onPressed: () => Navigator.of(context)
                .push(riseRoute(const BookingScreen())),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shield_outlined, size: 13, color: AppColors.faint),
              const SizedBox(width: 5),
              Text(
                'Verified mechanics · Free price chart',
                style: AppText.body(size: 11, color: AppColors.faint),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OngoingJobCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => Navigator.of(context)
          .push(riseRoute(const TrackingScreen(freshBooking: false))),
      padding: const EdgeInsets.all(16),
      color: AppColors.amberSoft,
      borderColor: AppColors.amber.withOpacity(0.35),
      child: Row(
        children: [
          const IconTile(icon: Icons.local_shipping_outlined,
              color: AppColors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active service',
                  style: AppText.body(size: 14, weight: FontWeight.w800),
                ),
                Text(
                  '${appState.status.label} · ${appState.mechanic?.name ?? 'Finding a mechanic'}',
                  style: AppText.body(size: 11.5, color: AppColors.muted),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_rounded,
              size: 18, color: AppColors.orange),
        ],
      ),
    );
  }
}

class _FreeTools extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tools = [
      (
        icon: Icons.table_rows_rounded,
        label: 'Price chart',
        color: AppColors.blue,
        page: const PriceChartScreen(),
      ),
      (
        icon: Icons.calculate_rounded,
        label: 'Cost estimate',
        color: AppColors.amber,
        page: const CostEstimatorScreen(),
      ),
      (
        icon: Icons.lightbulb_outline_rounded,
        label: 'Care tips',
        color: AppColors.purple,
        page: const MaintenanceTipsScreen(),
      ),
      (
        icon: Icons.emergency_rounded,
        label: 'Emergency',
        color: AppColors.coral,
        page: null,
      ),
    ];

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 8,
      childAspectRatio: 0.78,
      children: tools.map((tool) {
        return GestureDetector(
          onTap: () {
            if (tool.page == null) {
              showEmergencySheet(context);
            } else {
              Navigator.of(context).push(riseRoute(tool.page!));
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: tool.color.withOpacity(0.11),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(tool.icon, size: 20, color: tool.color),
                ),
                const SizedBox(height: 8),
                Text(
                  tool.label,
                  textAlign: TextAlign.center,
                  style: AppText.body(
                      size: 10.5,
                      weight: FontWeight.w600,
                      color: AppColors.ink),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PopularServices extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final services = popularServices.take(4).toList();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.35,
      ),
      itemBuilder: (context, index) {
        final service = services[index];
        return AppCard(
          onTap: () => Navigator.of(context).push(riseRoute(
              BookingScreen(initialServiceId: service.id,
                  vehicleId: service.vehicleId))),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.build_outlined,
                  size: 20, color: AppColors.teal.withOpacity(0.8)),
              const SizedBox(height: 10),
              Text(
                service.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.body(size: 12.5, weight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'from ${service.rangeLabel.split('–').first.trim()}',
                style: AppText.price(size: 14, color: AppColors.tealDark),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NearbyMechanicCard extends StatelessWidget {
  final MechanicPro mechanic;

  const _NearbyMechanicCard({required this.mechanic});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 218,
      child: AppCard(
        onTap: () => Navigator.of(context).push(
            riseRoute(MechanicDetailScreen(mechanic: mechanic))),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.tealSoft,
                  child: Text(
                    initials(mechanic.name),
                    style: AppText.label(
                        size: 13,
                        color: AppColors.tealDark,
                        weight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mechanic.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.body(
                            size: 12.5, weight: FontWeight.w700),
                      ),
                      Text(
                        mechanic.garage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.body(size: 10.5, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 14, color: AppColors.amber),
                      const SizedBox(width: 3),
                      Text('${mechanic.rating}',
                          style: AppText.body(
                              size: 11.5, weight: FontWeight.w700)),
                      Flexible(
                        child: Text(
                          ' (${mechanic.reviews})',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.body(
                              size: 10, color: AppColors.faint),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 13, color: AppColors.faint),
                    Text('${mechanic.baseDistanceKm} km',
                        style: AppText.body(
                            size: 10.5, color: AppColors.muted)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                StatusPill(
                  label: mechanic.isOnline ? 'Available now' : 'Busy',
                  color: mechanic.isOnline ? AppColors.teal : AppColors.faint,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void showEmergencySheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 30),
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
          const SizedBox(height: 18),
          Text('Emergency contacts', style: AppText.h2()),
          const SizedBox(height: 4),
          Text(
            'Quick help while you wait for a mechanic.',
            style: AppText.body(size: 12.5, color: AppColors.muted),
          ),
          const SizedBox(height: 14),
          _emergencyTile(Icons.local_hospital_outlined, 'Ambulance', '999',
              AppColors.coral),
          _emergencyTile(Icons.local_fire_department_outlined, 'Fire service',
              '999', AppColors.orange),
          _emergencyTile(Icons.shield_outlined, 'Police', '999',
              AppColors.blue),
          _emergencyTile(Icons.directions_car_rounded, 'CarAid support',
              '16358', AppColors.teal),
        ],
      ),
    ),
  );
}

Widget _emergencyTile(IconData icon, String label, String number, Color color) {
  return ListTile(
    contentPadding: EdgeInsets.zero,
    onTap: () async {
      final uri = Uri(scheme: 'tel', path: number);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    },
    leading: IconTile(icon: icon, color: color),
    title: Text(label, style: AppText.body(weight: FontWeight.w700)),
    subtitle: Text(number, style: AppText.body(size: 12, color: AppColors.muted)),
    trailing: const Icon(Icons.call_rounded, color: AppColors.teal),
  );
}
