import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../core/services/firebase_service.dart';
import '../core/services/location_service.dart';
import '../core/utils/formatters.dart';
import '../core/utils/geo.dart';
import '../data/demo_data.dart';
import '../models/booking.dart';
import '../models/mechanic_pro.dart';
import '../models/payment_method.dart';
import '../models/service_entry.dart';
import '../models/vehicle_type.dart';

/// Single source of truth for the demo experience.
///
/// Firebase is used for real authentication and best-effort persistence,
/// while the booking/tracking simulation works fully offline.
class AppState extends ChangeNotifier {
  AppState() {
    history.addAll(seedHistory());
    requests = demoRequests();
    _seedPayouts();
  }

  // ---------------------------------------------------------------------------
  // Session
  // ---------------------------------------------------------------------------
  UserRole? role;
  bool isDemoSession = false;
  String uid = '';
  String name = '';
  String email = '';
  String phone = '';

  bool _customerPremium = false;
  DateTime? _customerTrialEnd;
  String? _customerPlanPass;

  bool _mechanicPremium = false;
  DateTime? _mechanicTrialEnd;
  String? _mechanicPlanPass;

  bool get isSignedIn => role != null;
  bool get isCustomer => role == UserRole.customer;
  bool get isMechanic => role == UserRole.mechanic;

  bool get customerHasAccess =>
      _customerPremium ||
      (_customerTrialEnd?.isAfter(DateTime.now()) ?? false);

  bool get mechanicHasAccess =>
      _mechanicPremium ||
      (_mechanicTrialEnd?.isAfter(DateTime.now()) ?? false);

  bool get hasAccess => isMechanic ? mechanicHasAccess : customerHasAccess;

  DateTime? get trialEndsAt =>
      isMechanic ? _mechanicTrialEnd : _customerTrialEnd;

  String? get planPass => isMechanic ? _mechanicPlanPass : _customerPlanPass;

  String get accessLabel {
    if (isMechanic ? _mechanicPremium : _customerPremium) {
      return isMechanic ? 'Mechanic Premium' : 'Customer Premium';
    }
    final trial = trialEndsAt;
    if (trial != null && trial.isAfter(DateTime.now())) {
      return 'Free trial · ${_daysLeft(trial)} days left';
    }
    return 'Free plan';
  }

  String get firstName {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return isMechanic ? 'Mechanic' : 'there';
    return trimmed.split(' ').first;
  }

  void signInDemo(UserRole userRole) {
    resetJourney();
    role = userRole;
    isDemoSession = true;
    uid = 'demo-${userRole.name}';
    if (userRole == UserRole.customer) {
      name = 'Ayaan Chowdhury';
      email = 'ayaan@caraid.app';
      phone = '01712345678';
    } else {
      name = 'Rahim Uddin';
      email = 'rahim@caraid.app';
      phone = '01711020304';
      online = true;
    }
    notifyListeners();
  }

  Future<void> signInWithEmail(String userEmail, String password) async {
    final profile = await FirebaseService.instance.signIn(userEmail, password);
    _applyProfile(profile);
    notifyListeners();
  }

  Future<void> register({
    required String fullName,
    required String userPhone,
    required String userEmail,
    required String password,
    required UserRole userRole,
  }) async {
    final profile = await FirebaseService.instance.signUp(
      name: fullName,
      phone: userPhone,
      email: userEmail,
      password: password,
      role: userRole,
    );
    _applyProfile(profile);
    notifyListeners();
  }

  void _applyProfile(UserProfile profile) {
    resetJourney();
    uid = profile.uid;
    name = profile.name;
    email = profile.email;
    phone = profile.phone;
    isDemoSession = false;
    role = profile.role == 'mechanic' ? UserRole.mechanic : UserRole.customer;
    if (role == UserRole.customer) {
      _customerPremium = profile.isPremium;
      _customerTrialEnd = profile.trialEndsAt;
      _customerPlanPass = profile.planLabel;
    } else {
      _mechanicPremium = profile.isPremium;
      _mechanicTrialEnd = profile.trialEndsAt;
      _mechanicPlanPass = profile.planLabel;
    }
  }

  Future<void> signOut() async {
    await FirebaseService.instance.signOut();
    resetAll();
  }

  // ---------------------------------------------------------------------------
  // Subscription
  // ---------------------------------------------------------------------------
  void startTrial() {
    final until = DateTime.now().add(const Duration(days: 7));
    if (isMechanic) {
      _mechanicTrialEnd = until;
      _mechanicPlanPass = '7-day free trial';
    } else {
      _customerTrialEnd = until;
      _customerPlanPass = '7-day free trial';
    }
    notifyListeners();
  }

  Future<void> purchasePlan(SubscriptionPlan plan) async {
    final until = DateTime.now().add(Duration(days: plan.months * 30));
    final isMechPlan = plan.id.startsWith('mech');
    if (isMechPlan) {
      _mechanicPremium = true;
      _mechanicTrialEnd = null;
      _mechanicPlanPass = plan.name;
    } else {
      _customerPremium = true;
      _customerTrialEnd = null;
      _customerPlanPass = plan.name;
    }
    notifyListeners();
    if (uid.isNotEmpty) {
      await FirebaseService.instance.saveSubscription(
        uid: uid,
        plan: plan,
        activeUntil: until,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Customer journey
  // ---------------------------------------------------------------------------
  VehicleType selectedVehicle = vehicleTypes.first;
  final Set<String> _selectedServiceIds = <String>{};
  MechanicPro? mechanic;

  BookingStatus status = BookingStatus.idle;
  double progress = 0;
  double customerLat = demoLat;
  double customerLng = demoLng;
  double mechanicLat = demoLat + 0.010;
  double mechanicLng = demoLng - 0.004;

  double initialDistanceKm = 0;
  int etaMinutesValue = 0;

  final List<BillLine> billLines = [];
  BookingRecord? currentBooking;
  final List<BookingRecord> history = [];
  final List<ChatMessage> chat = [];

  Timer? _simTimer;
  Timer? _replyTimer;
  bool _locating = false;

  bool get isLocating => _locating;

  List<ServiceEntry> get selectedServices => allServices
      .where((service) => _selectedServiceIds.contains(service.id))
      .toList();

  bool isServiceSelected(String id) => _selectedServiceIds.contains(id);

  int get servicesEstimate =>
      selectedServices.fold(0, (sum, service) => sum + service.quote);

  double get travelDistanceKm => mechanic == null
      ? 0
      : math.max(
          0.6,
          haversineKm(customerLat, customerLng, mechanic!.lat, mechanic!.lng),
        );

  int get travelFee => travelFeeFor(travelDistanceKm);

  List<BillLine> get doneLines =>
      billLines.where((line) => line.done).toList();

  int get doneServicesTotal =>
      doneLines.fold(0, (sum, line) => sum + line.amount);

  int get billTotal => doneServicesTotal + travelFee;

  String get requestId =>
      currentBooking?.id ?? 'DEMO-${uid.hashCode.abs()}';

  void chooseVehicle(VehicleType vehicle) {
    if (selectedVehicle.id == vehicle.id) return;
    selectedVehicle = vehicle;
    _selectedServiceIds.clear();
    notifyListeners();
  }

  void toggleService(String serviceId) {
    if (!_selectedServiceIds.remove(serviceId)) {
      _selectedServiceIds.add(serviceId);
    }
    notifyListeners();
  }

  void clearServices() {
    _selectedServiceIds.clear();
    notifyListeners();
  }

  Future<bool> refreshLocation() async {
    _locating = true;
    notifyListeners();
    final position = await LocationService.current();
    _locating = false;
    if (position != null) {
      customerLat = position.lat;
      customerLng = position.lng;
    }
    notifyListeners();
    return position != null;
  }

  void selectMechanic(MechanicPro selected) {
    mechanic = selected;
    notifyListeners();
  }

  void startBooking(MechanicPro selected) {
    mechanic = selected;
    status = BookingStatus.searching;
    progress = 0;
    billLines.clear();
    currentBooking = null;
    mechanicLat = selected.lat;
    mechanicLng = selected.lng;
    initialDistanceKm = math.max(
      0.6,
      haversineKm(customerLat, customerLng, selected.lat, selected.lng),
    );
    etaMinutesValue = etaMinutesFor(initialDistanceKm);
    _seedChat(selected);
    _simTimer?.cancel();
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 1600), () {
      if (status == BookingStatus.searching) {
        status = BookingStatus.enRoute;
        _beginMovement();
        notifyListeners();
      }
    });
  }

  void _beginMovement() {
    _simTimer?.cancel();
    _simTimer = Timer.periodic(const Duration(milliseconds: 900), (timer) {
      if (status != BookingStatus.enRoute) {
        timer.cancel();
        return;
      }
      progress = (progress + 0.035).clamp(0.0, 1.0);
      final point = interpolatePoint(
        mechanic?.lat ?? mechanicLat,
        mechanic?.lng ?? mechanicLng,
        customerLat,
        customerLng,
        progress,
      );
      mechanicLat = point.lat;
      mechanicLng = point.lng;
      etaMinutesValue =
          etaMinutesFor(initialDistanceKm * (1 - progress) + 0.05);
      if (progress >= 1) {
        status = BookingStatus.arrived;
        etaMinutesValue = 0;
        timer.cancel();
      }
      notifyListeners();
    });
  }

  /// Fast-forwards the demo ride straight to the customer's location.
  void skipToArrival() {
    _simTimer?.cancel();
    progress = 1;
    mechanicLat = customerLat;
    mechanicLng = customerLng;
    status = BookingStatus.arrived;
    etaMinutesValue = 0;
    notifyListeners();
  }

  void startService() {
    if (billLines.isEmpty) {
      _seedBillLines();
    }
    status = BookingStatus.inProgress;
    notifyListeners();
  }

  void _seedBillLines() {
    final services = selectedServices.isNotEmpty
        ? selectedServices
        : popularServices
            .where((s) => s.vehicleId == selectedVehicle.id)
            .take(2)
            .toList();
    billLines
      ..clear()
      ..addAll(services.map((s) => BillLine(
            serviceId: s.id,
            name: s.name,
            amount: s.quote,
          )));
  }

  /// Called from the mechanic checklist. [lines] contains only checked items.
  void completeService(List<BillLine> lines) {
    billLines
      ..clear()
      ..addAll(lines);
    status = BookingStatus.completed;
    final record = _buildRecord(BookingStatus.completed);
    currentBooking = record;
    notifyListeners();
    FirebaseService.instance.saveBooking(uid, record);
  }

  void pay(PaymentMethod method) {
    final record = _buildRecord(
      BookingStatus.paid,
      method: method,
      txn: txnId(),
    );
    currentBooking = record;
    status = BookingStatus.paid;
    history.insert(0, record);
    notifyListeners();
    FirebaseService.instance.saveBooking(uid, record);
  }

  BookingRecord _buildRecord(
    BookingStatus bookingStatus, {
    PaymentMethod? method,
    String? txn,
  }) {
    final title = doneLines.isEmpty
        ? 'Vehicle service'
        : doneLines.length == 1
            ? doneLines.first.name
            : '${doneLines.first.name} + ${doneLines.length - 1} more';
    return BookingRecord(
      id: currentBooking?.id ??
          'BK${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      title: title,
      vehicle: selectedVehicle.name,
      mechanicName: mechanic?.name ?? 'CarAid mechanic',
      date: DateTime.now(),
      lines: doneLines.map((line) => BillLine(
            serviceId: line.serviceId,
            name: line.name,
            amount: line.amount,
            done: true,
          )).toList(),
      travelFee: travelFee,
      status: bookingStatus,
      method: method ?? currentBooking?.method,
      txn: txn ?? currentBooking?.txn,
    );
  }

  void resetJourney() {
    _simTimer?.cancel();
    _replyTimer?.cancel();
    status = BookingStatus.idle;
    progress = 0;
    mechanic = null;
    _selectedServiceIds.clear();
    billLines.clear();
    currentBooking = null;
    chat.clear();
    etaMinutesValue = 0;
    selectedVehicle = vehicleTypes.first;
    notifyListeners();
  }

  void cancelBooking() {
    _simTimer?.cancel();
    status = BookingStatus.cancelled;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Chat
  // ---------------------------------------------------------------------------
  void _seedChat(MechanicPro selected) {
    chat
      ..clear()
      ..add(ChatMessage(
        text:
            'Assalamu alaikum! I am ${selected.firstName} from ${selected.garage}. I have accepted your request and I am on the way.',
        mine: false,
        time: DateTime.now().subtract(const Duration(minutes: 2)),
      ))
      ..add(ChatMessage(
        text: 'Please share your exact location if it is hard to find.',
        mine: false,
        time: DateTime.now().subtract(const Duration(minutes: 1)),
      ));
  }

  void sendChat(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    chat.add(ChatMessage(text: trimmed, mine: true));
    notifyListeners();
    if (currentBooking != null || uid.isNotEmpty) {
      FirebaseService.instance.sendChatMessage(
        bookingId: requestId,
        text: trimmed,
        fromCustomer: isCustomer,
      );
    }

    _replyTimer?.cancel();
    final replies = [
      'Got it, I will be there shortly.',
      'Understood. I have the tools with me.',
      'Thanks! I am about 5 minutes away.',
      'No problem, please keep the vehicle accessible.',
    ];
    _replyTimer = Timer(const Duration(milliseconds: 1600), () {
      chat.add(ChatMessage(
        text: replies[chat.length % replies.length],
        mine: false,
      ));
      notifyListeners();
    });
  }

  // ---------------------------------------------------------------------------
  // Mechanic workspace
  // ---------------------------------------------------------------------------
  bool online = true;
  List<JobRequest> requests = [];
  JobRequest? activeRequest;
  int todayEarnings = 2840;
  int weekEarnings = 12750;
  int monthEarnings = 48200;
  int jobsToday = 4;
  double mechanicRating = 4.9;
  final List<BookingRecord> payouts = [];

  void setOnline(bool value) {
    online = value;
    notifyListeners();
    if (uid.isNotEmpty) {
      FirebaseService.instance.setOnline(uid, value);
    }
  }

  void acceptRequest(JobRequest request) {
    activeRequest = request;
    requests.removeWhere((r) => r.id == request.id);
    notifyListeners();
  }

  void declineRequest(String id) {
    requests.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  void completeMechanicJob(List<BillLine> lines, int travel) {
    final done = lines.where((line) => line.done).toList();
    final services = done.fold(0, (sum, line) => sum + line.amount);
    final total = services + travel;
    final request = activeRequest;
    final record = BookingRecord(
      id: 'JOB${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      title: done.isEmpty ? 'Vehicle service' : done.first.name,
      vehicle: request?.vehicle ?? 'Vehicle',
      mechanicName: name,
      date: DateTime.now(),
      lines: done,
      travelFee: travel,
      status: BookingStatus.paid,
      method: PaymentMethod.cash,
      txn: txnId(),
    );
    payouts.insert(0, record);
    todayEarnings += total;
    weekEarnings += total;
    monthEarnings += total;
    jobsToday += 1;
    activeRequest = null;
    notifyListeners();
  }

  void _seedPayouts() {
    final now = DateTime.now();
    payouts.addAll([
      BookingRecord(
        id: 'pay-1',
        title: 'Brake pad replacement',
        vehicle: 'Toyota Axio',
        mechanicName: 'You',
        date: now.subtract(const Duration(hours: 2)),
        travelFee: 95,
        status: BookingStatus.paid,
        method: PaymentMethod.bkash,
        txn: 'CRD90124551',
        lines: [
          BillLine(serviceId: 'car-brake', name: 'Brake Pad', amount: 2750),
        ],
      ),
      BookingRecord(
        id: 'pay-2',
        title: 'AC gas refill',
        vehicle: 'Honda Vezel',
        mechanicName: 'You',
        date: now.subtract(const Duration(hours: 5)),
        travelFee: 120,
        status: BookingStatus.paid,
        method: PaymentMethod.nagad,
        txn: 'CRD78231904',
        lines: [
          BillLine(serviceId: 'car-ac', name: 'AC Gas Refill', amount: 3380),
        ],
      ),
    ]);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------
  String _daysLeft(DateTime until) {
    final diff = until.difference(DateTime.now()).inDays;
    return math.max(0, diff).toString();
  }

  void resetAll() {
    role = null;
    isDemoSession = false;
    uid = '';
    name = '';
    email = '';
    phone = '';
    _customerPremium = false;
    _customerTrialEnd = null;
    _customerPlanPass = null;
    _mechanicPremium = false;
    _mechanicTrialEnd = null;
    _mechanicPlanPass = null;
    online = true;
    activeRequest = null;
    requests = demoRequests();
    resetJourney();
  }

  @override
  void dispose() {
    _simTimer?.cancel();
    _replyTimer?.cancel();
    super.dispose();
  }
}

/// Global instance used by the CarAid screens.
final AppState appState = AppState();
