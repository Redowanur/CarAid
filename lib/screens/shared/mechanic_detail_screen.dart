import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/geo.dart';
import '../../core/utils/ui.dart';
import '../../models/mechanic_pro.dart';
import '../../state/app_state.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/paywall_sheet.dart';
import '../customer/booking_screen.dart';

class MechanicDetailScreen extends StatelessWidget {
  final MechanicPro mechanic;

  const MechanicDetailScreen({super.key, required this.mechanic});

  @override
  Widget build(BuildContext context) {
    final distanceKm = math.max(
      0.6,
      haversineKm(
        appState.customerLat,
        appState.customerLng,
        mechanic.lat,
        mechanic.lng,
      ),
    );

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Hero(mechanic: mechanic),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(mechanic.name, style: AppText.h1()),
                          ),
                          StatusPill(
                            label: mechanic.isOnline ? 'AVAILABLE' : 'BUSY',
                            color: mechanic.isOnline
                                ? AppColors.teal
                                : AppColors.faint,
                            icon: Icons.circle,
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${mechanic.garage} · ${mechanic.experienceLabel}',
                        style: AppText.body(size: 13, color: AppColors.muted),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _StatTile(
                              icon: Icons.star_rounded,
                              color: AppColors.amber,
                              value: '${mechanic.rating}',
                              label: '${mechanic.reviews} reviews',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StatTile(
                              icon: Icons.work_outline_rounded,
                              color: AppColors.blue,
                              value: '${mechanic.jobsDone}',
                              label: 'Jobs done',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StatTile(
                              icon: Icons.location_on_outlined,
                              color: AppColors.teal,
                              value: distance(distanceKm),
                              label: 'Away',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Text('Specialties', style: AppText.h3()),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: mechanic.specialties
                            .map(
                              (s) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 13, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.tealSoft,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  s,
                                  style: AppText.label(
                                    size: 12,
                                    color: AppColors.tealDark,
                                    weight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 22),
                      Text('About', style: AppText.h3()),
                      const SizedBox(height: 8),
                      Text(
                        '${mechanic.firstName} has been serving Dhaka drivers for ${mechanic.experienceYears} years. '
                        'Verified by CarAid, equipped for on-site repairs and known for transparent billing.',
                        style: AppText.body(
                          size: 13,
                          color: AppColors.muted,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 18),
                      AppCard(
                        padding: const EdgeInsets.all(16),
                        color: AppColors.blue.withOpacity(0.04),
                        borderColor: AppColors.blue.withOpacity(0.18),
                        child: Row(
                          children: [
                            const IconTile(
                              icon: Icons.route_outlined,
                              color: AppColors.blue,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Travel charge',
                                      style: AppText.body(
                                          size: 13, weight: FontWeight.w700)),
                                  Text(
                                    '${distance(distanceKm)} · ৳60 base + ৳18/km',
                                    style: AppText.body(
                                        size: 11, color: AppColors.muted),
                                  ),
                                ],
                              ),
                            ),
                            Text(money(travelFeeFor(distanceKm)),
                                style: AppText.price(size: 16)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _TopBar(),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomBar(mechanic: mechanic),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.navy.withOpacity(0.55),
            AppColors.navy.withOpacity(0.0),
          ],
        ),
      ),
      padding: EdgeInsets.fromLTRB(
          16, MediaQuery.of(context).padding.top + 10, 16, 30),
      child: Row(
        children: [
          CircleIconButton(
            icon: Icons.arrow_back_rounded,
            background: AppColors.white,
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          CircleIconButton(
            icon: Icons.share_outlined,
            background: AppColors.white.withOpacity(0.9),
            onPressed: () => showAppSnack(
                context, 'Share this mechanic with a friend coming soon.'),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final MechanicPro mechanic;

  const _Hero({required this.mechanic});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      decoration: const BoxDecoration(
        gradient: AppColors.navyGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: -80,
            right: -70,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.teal.withOpacity(0.12),
              ),
            ),
          ),
          Positioned(
            bottom: -90,
            left: -50,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.amber.withOpacity(0.08),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.amber.withOpacity(0.7), width: 2),
                ),
                child: CircleAvatar(
                  radius: 52,
                  backgroundColor: AppColors.teal.withOpacity(0.2),
                  child: Text(
                    initials(mechanic.name),
                    style: AppText.display(30, color: AppColors.white),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Verified mechanic',
                style: AppText.label(
                  size: 11.5,
                  color: AppColors.white.withOpacity(0.7),
                  weight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _StatTile({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 6),
          Text(value,
              style: AppText.body(size: 14, weight: FontWeight.w800)),
          Text(label,
              style: AppText.body(size: 9.5, color: AppColors.faint)),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final MechanicPro mechanic;

  const _BottomBar({required this.mechanic});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Color(0x140D1B2A),
            blurRadius: 22,
            offset: Offset(0, -8),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).padding.bottom + 14),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            CircleIconButton(
              icon: Icons.phone_outlined,
              background: AppColors.tealSoft,
              foreground: AppColors.tealDark,
              size: 52,
              onPressed: () async {
                final allowed = await ensureAccess(context);
                if (!allowed) return;
                final uri = Uri(scheme: 'tel', path: mechanic.phone);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PrimaryButton(
                label: 'Book this mechanic',
                icon: Icons.near_me_rounded,
                onPressed: () => Navigator.of(context).push(riseRoute(
                  BookingScreen(
                    initialMechanicId: mechanic.id,
                    vehicleId: appState.selectedVehicle.id,
                  ),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
