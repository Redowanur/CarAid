import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/ui.dart';
import '../../models/booking.dart';
import '../../models/mechanic_pro.dart';
import '../../state/app_state.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/paywall_sheet.dart';
import '../shared/chat_screen.dart';
import 'checklist_screen.dart';
import 'bill_screen.dart';

class TrackingScreen extends StatefulWidget {
  /// True when opened straight after confirming a new booking.
  final bool freshBooking;

  const TrackingScreen({super.key, this.freshBooking = true});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();
  static const _mapStyle = '[{"featureType":"poi","stylers":[{"visibility":"off"}]},'
      '{"featureType":"transit","stylers":[{"visibility":"off"}]},'
      '{"featureType":"road","elementType":"geometry","stylers":[{"color":"#e8edf2"}]},'
      '{"featureType":"water","stylers":[{"color":"#cfe8e8"}]},'
      '{"featureType":"landscape","stylers":[{"color":"#f5f8fa"}]}]';

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final mechanic = appState.mechanic;
        final active = appState.status != BookingStatus.idle &&
            appState.status != BookingStatus.paid &&
            appState.status != BookingStatus.cancelled;

        return Scaffold(
          body: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(appState.customerLat, appState.customerLng),
                  zoom: 14.6,
                ),
                onMapCreated: (controller) {
                  _mapController.complete(controller);
                  controller.setMapStyle(_mapStyle);
                },
                markers: _markers(),
                polylines: _polylines(),
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                compassEnabled: false,
                mapToolbarEnabled: false,
                padding: const EdgeInsets.only(bottom: 290),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _topBar(context),
              ),
              if (!active)
                Center(
                  child: AppCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            size: 30, color: AppColors.muted),
                        const SizedBox(height: 10),
                        Text('No active service', style: AppText.h3()),
                        const SizedBox(height: 6),
                        Text(
                          'Book a mechanic to see live tracking here.',
                          style: AppText.body(
                              size: 12.5, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                ),
              if (active && mechanic != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _TrackingPanel(mechanic: mechanic, parentContext: context),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _topBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.navy.withOpacity(0.92),
            AppColors.navy.withOpacity(0.0),
          ],
        ),
      ),
      padding: EdgeInsets.fromLTRB(
          16, MediaQuery.of(context).padding.top + 10, 16, 40),
      child: Row(
        children: [
          CircleIconButton(
            icon: Icons.arrow_back_rounded,
            background: AppColors.white,
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Live service',
                  style: AppText.body(
                      size: 16, weight: FontWeight.w700, color: AppColors.white)),
              Text('Your mechanic is on the move',
                  style: AppText.body(
                      size: 11, color: AppColors.white.withOpacity(0.7))),
            ],
          ),
          const Spacer(),
          const StatusPill(
            label: 'LIVE',
            color: AppColors.teal,
            icon: Icons.fiber_manual_record_rounded,
          ),
        ],
      ),
    );
  }

  Set<Marker> _markers() {
    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('customer'),
        position: LatLng(appState.customerLat, appState.customerLng),
        infoWindow: const InfoWindow(title: 'Your location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    };
    final mechanic = appState.mechanic;
    if (mechanic != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('mechanic'),
          position: LatLng(appState.mechanicLat, appState.mechanicLng),
          infoWindow: InfoWindow(title: mechanic.name, snippet: 'Your mechanic'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
    }
    return markers;
  }

  Set<Polyline> _polylines() {
    final mechanic = appState.mechanic;
    if (mechanic == null) return {};
    return {
      Polyline(
        polylineId: const PolylineId('route'),
        color: AppColors.teal,
        width: 4,
        patterns: [
          PatternItem.dash(14),
          PatternItem.gap(8),
        ],
        points: [
          LatLng(mechanic.lat, mechanic.lng),
          LatLng(appState.customerLat, appState.customerLng),
        ],
      ),
    };
  }
}

class _TrackingPanel extends StatelessWidget {
  final MechanicPro mechanic;
  final BuildContext parentContext;

  const _TrackingPanel({
    required this.mechanic,
    required this.parentContext,
  });

  @override
  Widget build(BuildContext context) {
    final status = appState.status;
    final arrived = status == BookingStatus.arrived;
    final completed = status == BookingStatus.completed;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A0D1B2A),
            blurRadius: 28,
            offset: Offset(0, -10),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: SafeArea(
        top: false,
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
            const SizedBox(height: 16),
            Row(
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
                      Text(mechanic.name,
                          style: AppText.body(
                              size: 14.5, weight: FontWeight.w700)),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 13, color: AppColors.amber),
                          Text(' ${mechanic.rating} · ${mechanic.garage}',
                              style: AppText.body(
                                  size: 11, color: AppColors.muted)),
                        ],
                      ),
                    ],
                  ),
                ),
                CircleIconButton(
                  icon: Icons.phone_in_talk_rounded,
                  background: AppColors.tealSoft,
                  foreground: AppColors.tealDark,
                  size: 42,
                  onPressed: () => _call(mechanic.phone),
                ),
                const SizedBox(width: 8),
                CircleIconButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  background: AppColors.blueSoft,
                  foreground: AppColors.blue,
                  size: 42,
                  onPressed: () async {
                    final allowed = await ensureAccess(parentContext);
                    if (allowed && parentContext.mounted) {
                      Navigator.of(parentContext)
                          .push(riseRoute(const ChatScreen()));
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cloud,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: arrived ? AppColors.tealSoft : AppColors.amberSoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      arrived
                          ? Icons.check_circle_outline_rounded
                          : Icons.two_wheeler_rounded,
                      color: arrived ? AppColors.teal : AppColors.orange,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          arrived
                              ? 'Your mechanic has arrived'
                              : status == BookingStatus.inProgress
                                  ? 'Service in progress'
                                  : completed
                                      ? 'Service completed'
                                      : 'Arriving in ${minutes(appState.etaMinutesValue)}',
                          style: AppText.body(
                              size: 14, weight: FontWeight.w800),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          arrived
                              ? 'You can start the service checklist now.'
                              : 'Live location updates every second.',
                          style: AppText.body(
                              size: 11.5, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _StepProgress(status: status),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: appState.progress.clamp(0.0, 1.0),
                minHeight: 7,
              ),
            ),
            const SizedBox(height: 16),
            if (completed)
              PrimaryButton(
                label: 'View itemized bill',
                icon: Icons.receipt_long_rounded,
                onPressed: () => Navigator.of(context).push(
                  riseRoute(const BillScreen()),
                ),
              )
            else if (status == BookingStatus.inProgress)
              PrimaryButton(
                label: 'Open service checklist',
                icon: Icons.checklist_rounded,
                onPressed: () => Navigator.of(context).push(
                  riseRoute(const ChecklistScreen(roleContext: 'customer')),
                ),
              )
            else if (arrived)
              PrimaryButton(
                label: 'Mechanic is here · Start service',
                icon: Icons.play_arrow_rounded,
                onPressed: () {
                  appState.startService();
                  Navigator.of(context).push(
                    riseRoute(const ChecklistScreen(roleContext: 'customer')),
                  );
                },
              )
            else
              PrimaryButton(
                label: 'Simulate arrival (demo)',
                icon: Icons.fast_forward_rounded,
                background: AppColors.ink,
                onPressed: () => appState.skipToArrival(),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _call(String phone) async {
    final allowed = await ensureAccess(parentContext);
    if (!allowed) return;
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _StepProgress extends StatelessWidget {
  final BookingStatus status;

  const _StepProgress({required this.status});

  @override
  Widget build(BuildContext context) {
    final step = status.step;
    final labels = ['Confirmed', 'On the way', 'Arrived', 'In service', 'Bill'];
    return Row(
      children: List.generate(labels.length, (index) {
        final active = index <= step;
        return Expanded(
          child: Column(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: active ? AppColors.teal : AppColors.border,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: active
                    ? const Icon(Icons.check_rounded,
                        size: 14, color: AppColors.white)
                    : Text(
                        '${index + 1}',
                        style: AppText.label(
                            size: 10, color: AppColors.faint),
                      ),
              ),
              const SizedBox(height: 5),
              Text(
                labels[index],
                textAlign: TextAlign.center,
                style: AppText.body(
                    size: 9,
                    color: active ? AppColors.tealDark : AppColors.faint,
                    weight: active ? FontWeight.w700 : FontWeight.w500),
              ),
            ],
          ),
        );
      }),
    );
  }
}
