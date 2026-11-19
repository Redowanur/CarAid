import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/booking.dart';
import '../models/mechanic_pro.dart';
import '../models/payment_method.dart';
import '../models/service_entry.dart';
import '../models/vehicle_type.dart';

/// Default map centre used for demos (Gulshan 2, Dhaka).
const double demoLat = 23.7925;
const double demoLng = 90.4078;

const List<VehicleType> vehicleTypes = [
  VehicleType(
    id: 'car',
    name: 'Car',
    subtitle: 'Sedan, SUV & hatchback',
    icon: Icons.directions_car_filled_rounded,
  ),
  VehicleType(
    id: 'bike',
    name: 'Bike',
    subtitle: 'Motorcycle & scooter',
    icon: Icons.two_wheeler_rounded,
  ),
  VehicleType(
    id: 'cng',
    name: 'CNG',
    subtitle: 'Auto-rickshaw',
    icon: Icons.electric_rickshaw_rounded,
  ),
  VehicleType(
    id: 'truck',
    name: 'Truck',
    subtitle: 'Pickup & commercial',
    icon: Icons.local_shipping_rounded,
  ),
];

const List<ServiceEntry> allServices = [
  // Cars
  ServiceEntry(
    id: 'car-oil',
    vehicleId: 'car',
    name: 'Oil & Filter Change',
    note: 'Engine oil, oil filter & top-up',
    minPrice: 1200,
    maxPrice: 3500,
    durationMins: 45,
    popular: true,
  ),
  ServiceEntry(
    id: 'car-general',
    vehicleId: 'car',
    name: 'General Servicing',
    note: 'Full inspection and tune-up',
    minPrice: 2000,
    maxPrice: 6000,
    durationMins: 120,
  ),
  ServiceEntry(
    id: 'car-brake',
    vehicleId: 'car',
    name: 'Brake Pad Replacement',
    note: 'Front or rear pads, labour included',
    minPrice: 1800,
    maxPrice: 4500,
    durationMins: 60,
    popular: true,
  ),
  ServiceEntry(
    id: 'car-battery',
    vehicleId: 'car',
    name: 'Battery Replacement',
    note: 'Genuine battery with warranty',
    minPrice: 5500,
    maxPrice: 12000,
    durationMins: 30,
  ),
  ServiceEntry(
    id: 'car-puncture',
    vehicleId: 'car',
    name: 'Tyre Puncture Repair',
    note: 'On-site tube / tubeless repair',
    minPrice: 300,
    maxPrice: 900,
    durationMins: 25,
    popular: true,
  ),
  ServiceEntry(
    id: 'car-alignment',
    vehicleId: 'car',
    name: 'Wheel Alignment',
    note: 'Alignment and wheel balancing',
    minPrice: 800,
    maxPrice: 1800,
    durationMins: 45,
  ),
  ServiceEntry(
    id: 'car-ac',
    vehicleId: 'car',
    name: 'AC Gas Refill',
    note: 'Leak check and refrigerant refill',
    minPrice: 2500,
    maxPrice: 5000,
    durationMins: 60,
  ),
  ServiceEntry(
    id: 'car-diagnostics',
    vehicleId: 'car',
    name: 'Engine Diagnostics',
    note: 'Computer scan and fault report',
    minPrice: 800,
    maxPrice: 2000,
    durationMins: 30,
    popular: true,
  ),
  ServiceEntry(
    id: 'car-suspension',
    vehicleId: 'car',
    name: 'Suspension Repair',
    note: 'Shock absorbers, bushings & arms',
    minPrice: 3000,
    maxPrice: 10000,
    durationMins: 150,
  ),
  ServiceEntry(
    id: 'car-clutch',
    vehicleId: 'car',
    name: 'Clutch Replacement',
    note: 'Clutch plate, pressure plate & bearing',
    minPrice: 6000,
    maxPrice: 18000,
    durationMins: 180,
  ),

  // Bikes
  ServiceEntry(
    id: 'bike-oil',
    vehicleId: 'bike',
    name: 'Engine Oil Change',
    note: 'Mineral or synthetic oil',
    minPrice: 350,
    maxPrice: 900,
    durationMins: 20,
    popular: true,
  ),
  ServiceEntry(
    id: 'bike-chain',
    vehicleId: 'bike',
    name: 'Chain Adjustment',
    note: 'Clean, lube and adjust chain',
    minPrice: 150,
    maxPrice: 400,
    durationMins: 15,
  ),
  ServiceEntry(
    id: 'bike-brake',
    vehicleId: 'bike',
    name: 'Brake Shoe Replacement',
    note: 'Front or rear brake shoes',
    minPrice: 300,
    maxPrice: 800,
    durationMins: 25,
  ),
  ServiceEntry(
    id: 'bike-puncture',
    vehicleId: 'bike',
    name: 'Puncture Repair',
    note: 'Tube repair or replacement',
    minPrice: 100,
    maxPrice: 300,
    durationMins: 15,
    popular: true,
  ),
  ServiceEntry(
    id: 'bike-carb',
    vehicleId: 'bike',
    name: 'Carburetor Cleaning',
    note: 'Clean and tune carburetor',
    minPrice: 300,
    maxPrice: 700,
    durationMins: 35,
  ),
  ServiceEntry(
    id: 'bike-service',
    vehicleId: 'bike',
    name: 'Full Servicing',
    note: 'Complete bike tune-up package',
    minPrice: 800,
    maxPrice: 2500,
    durationMins: 90,
    popular: true,
  ),
  ServiceEntry(
    id: 'bike-battery',
    vehicleId: 'bike',
    name: 'Battery Replacement',
    note: 'Sealed battery with warranty',
    minPrice: 2000,
    maxPrice: 4500,
    durationMins: 20,
  ),
  ServiceEntry(
    id: 'bike-clutch',
    vehicleId: 'bike',
    name: 'Clutch Plate Replacement',
    note: 'Clutch plates and springs',
    minPrice: 1200,
    maxPrice: 3500,
    durationMins: 60,
  ),

  // CNG
  ServiceEntry(
    id: 'cng-oil',
    vehicleId: 'cng',
    name: 'Engine Oil Change',
    note: 'Oil and filter for CNG engines',
    minPrice: 500,
    maxPrice: 1100,
    durationMins: 30,
    popular: true,
  ),
  ServiceEntry(
    id: 'cng-brake',
    vehicleId: 'cng',
    name: 'Brake Adjustment',
    note: 'Adjust or replace brake shoes',
    minPrice: 400,
    maxPrice: 1000,
    durationMins: 30,
  ),
  ServiceEntry(
    id: 'cng-puncture',
    vehicleId: 'cng',
    name: 'Puncture Repair',
    note: 'On-site tyre repair',
    minPrice: 150,
    maxPrice: 400,
    durationMins: 20,
    popular: true,
  ),
  ServiceEntry(
    id: 'cng-battery',
    vehicleId: 'cng',
    name: 'Battery Replacement',
    note: '12V battery with warranty',
    minPrice: 2500,
    maxPrice: 5000,
    durationMins: 20,
  ),
  ServiceEntry(
    id: 'cng-general',
    vehicleId: 'cng',
    name: 'General Servicing',
    note: 'Full inspection and tune-up',
    minPrice: 1200,
    maxPrice: 3000,
    durationMins: 90,
  ),
  ServiceEntry(
    id: 'cng-wiring',
    vehicleId: 'cng',
    name: 'Electrical & Wiring',
    note: 'Lights, horn and wiring fixes',
    minPrice: 500,
    maxPrice: 1500,
    durationMins: 45,
  ),

  // Trucks & pickups
  ServiceEntry(
    id: 'truck-oil',
    vehicleId: 'truck',
    name: 'Oil & Filter Service',
    note: 'Heavy-duty engine oil change',
    minPrice: 2500,
    maxPrice: 6000,
    durationMins: 60,
    popular: true,
  ),
  ServiceEntry(
    id: 'truck-brake',
    vehicleId: 'truck',
    name: 'Brake Overhaul',
    note: 'Pads, drums and air lines',
    minPrice: 3000,
    maxPrice: 8000,
    durationMins: 120,
  ),
  ServiceEntry(
    id: 'truck-tyre',
    vehicleId: 'truck',
    name: 'Tyre & Puncture',
    note: 'Tyre repair or replacement',
    minPrice: 800,
    maxPrice: 2000,
    durationMins: 45,
  ),
  ServiceEntry(
    id: 'truck-battery',
    vehicleId: 'truck',
    name: 'Battery Replacement',
    note: 'Heavy-duty battery',
    minPrice: 8000,
    maxPrice: 18000,
    durationMins: 30,
  ),
  ServiceEntry(
    id: 'truck-suspension',
    vehicleId: 'truck',
    name: 'Suspension Repair',
    note: 'Leaf springs and shock absorbers',
    minPrice: 6000,
    maxPrice: 15000,
    durationMins: 180,
  ),
  ServiceEntry(
    id: 'truck-engine',
    vehicleId: 'truck',
    name: 'Engine Diagnostics',
    note: 'Fault scan and compression test',
    minPrice: 5000,
    maxPrice: 15000,
    durationMins: 90,
  ),
];

List<ServiceEntry> servicesForVehicle(String vehicleId) =>
    allServices.where((s) => s.vehicleId == vehicleId).toList();

List<ServiceEntry> get popularServices =>
    allServices.where((s) => s.popular).toList();

const List<MechanicPro> demoMechanics = [
  MechanicPro(
    id: 'm1',
    name: 'Rahim Uddin',
    garage: 'Rahim Auto Care',
    rating: 4.9,
    reviews: 212,
    experienceYears: 9,
    specialties: ['Engine', 'Brakes', 'Suspension'],
    phone: '01711020304',
    lat: 23.8005,
    lng: 90.4032,
    jobsDone: 1240,
    baseDistanceKm: 1.1,
  ),
  MechanicPro(
    id: 'm2',
    name: 'Sohel Ahmed',
    garage: 'Gulshan Motors',
    rating: 4.8,
    reviews: 168,
    experienceYears: 7,
    specialties: ['AC', 'Electrical', 'Diagnostics'],
    phone: '01811447788',
    lat: 23.7806,
    lng: 90.4146,
    jobsDone: 980,
    baseDistanceKm: 2.2,
  ),
  MechanicPro(
    id: 'm3',
    name: 'Kabir Hossain',
    garage: 'Banani Bike Lab',
    rating: 4.7,
    reviews: 143,
    experienceYears: 6,
    specialties: ['Bikes', 'Engine', 'Chain'],
    phone: '01911998877',
    lat: 23.7937,
    lng: 90.3892,
    jobsDone: 760,
    baseDistanceKm: 1.9,
  ),
  MechanicPro(
    id: 'm4',
    name: 'Jahid Hasan',
    garage: 'Tejgaon Tyre House',
    rating: 4.6,
    reviews: 96,
    experienceYears: 5,
    specialties: ['Tyres', 'Alignment', 'Puncture'],
    phone: '01677224455',
    lat: 23.7701,
    lng: 90.4001,
    jobsDone: 540,
    baseDistanceKm: 2.8,
  ),
  MechanicPro(
    id: 'm5',
    name: 'Shafiq Islam',
    garage: 'Bashundhara Auto Hub',
    rating: 4.9,
    reviews: 240,
    experienceYears: 11,
    specialties: ['Engine', 'Clutch', 'AC'],
    phone: '01555009911',
    lat: 23.8231,
    lng: 90.4270,
    jobsDone: 1590,
    baseDistanceKm: 3.6,
  ),
  MechanicPro(
    id: 'm6',
    name: 'Rasel Mia',
    garage: 'Dhanmondi Car Clinic',
    rating: 4.5,
    reviews: 71,
    experienceYears: 4,
    specialties: ['General', 'Battery', 'Oil'],
    phone: '01788332211',
    lat: 23.7461,
    lng: 90.3760,
    jobsDone: 390,
    baseDistanceKm: 6.2,
    isOnline: false,
  ),
];

List<SubscriptionPlan> plansForRole(UserRole role) {
  if (role == UserRole.mechanic) {
    return const [
      SubscriptionPlan(
        id: 'mech-monthly',
        name: 'Mechanic Monthly',
        price: 299,
        period: '/month',
        months: 1,
        perks: [
          'Unlimited job requests',
          'Priority placement in search',
          'In-app chat with customers',
          'Digital itemized billing',
        ],
      ),
      SubscriptionPlan(
        id: 'mech-yearly',
        name: 'Mechanic Yearly',
        price: 2999,
        period: '/year',
        months: 12,
        popular: true,
        perks: [
          '2 months free vs monthly',
          'Unlimited job requests',
          'Top search placement',
          'Earnings dashboard & payouts',
        ],
      ),
    ];
  }
  return const [
    SubscriptionPlan(
      id: 'cust-monthly',
      name: 'Customer Monthly',
      price: 199,
      period: '/month',
      months: 1,
      perks: [
        'Live mechanic tracking',
        'Chat & call your mechanic',
        'Book on-demand service',
        'Cashless bKash / Nagad / Rocket',
      ],
    ),
    SubscriptionPlan(
      id: 'cust-yearly',
      name: 'Customer Yearly',
      price: 1999,
      period: '/year',
      months: 12,
      popular: true,
      perks: [
        '2 months free vs monthly',
        'Live mechanic tracking',
        'Priority nearest mechanic',
        'Digital service history',
      ],
    ),
  ];
}

const List<String> freeFeatures = [
  'Full service price chart',
  'Repair cost estimator',
  'Browse nearby mechanics',
  'Maintenance tips & reminders',
  'Emergency contact sheet',
];

const List<String> premiumFeatures = [
  'Live GPS mechanic tracking',
  'In-app chat & phone calls',
  'On-demand booking',
  'Cashless bKash / Nagad / Rocket',
  'Itemized digital bills',
];

List<JobRequest> demoRequests() => [
      JobRequest(
        id: 'r1',
        customerName: 'Sadia Rahman',
        area: 'Bashundhara R/A',
        vehicle: 'Toyota Axio',
        problem: 'Brake noise & soft pedal',
        distanceKm: 2.4,
        payout: 2350,
        urgent: true,
        createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
      JobRequest(
        id: 'r2',
        customerName: 'Tanvir Ahmed',
        area: 'Gulshan 2',
        vehicle: 'Yamaha FZS',
        problem: 'Chain slipping',
        distanceKm: 1.2,
        payout: 780,
        urgent: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 9)),
      ),
      JobRequest(
        id: 'r3',
        customerName: 'Nusrat Jahan',
        area: 'Baridhara',
        vehicle: 'Honda Vezel',
        problem: 'AC not cooling',
        distanceKm: 3.8,
        payout: 3200,
        urgent: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 14)),
      ),
    ];

class MaintenanceTip {
  final String title;
  final String body;
  final IconData icon;
  final Color accent;

  const MaintenanceTip(this.title, this.body, this.icon, this.accent);
}

const List<MaintenanceTip> maintenanceTips = [
  MaintenanceTip(
    'Check tyre pressure monthly',
    'Low pressure wears tyres faster and increases fuel use. Use the sticker inside your driver door for the correct PSI.',
    Icons.tire_repair_rounded,
    AppColors.blue,
  ),
  MaintenanceTip(
    'Change engine oil on time',
    'Most cars need an oil change every 5,000–7,500 km. Dusty Dhaka traffic means the shorter interval is safer.',
    Icons.opacity_rounded,
    AppColors.amber,
  ),
  MaintenanceTip(
    'Listen for brake squeaks',
    'A high-pitched squeal usually means worn pads. Replace them early — rotors are far more expensive.',
    Icons.disc_full_rounded,
    AppColors.coral,
  ),
  MaintenanceTip(
    'Keep the battery clean',
    'Clean terminals and check for corrosion every 3 months. A weak battery is the most common cause of no-start mornings.',
    Icons.battery_charging_full_rounded,
    AppColors.teal,
  ),
  MaintenanceTip(
    'Cool down before AC off',
    'Switch off the AC a minute before the engine to dry the evaporator and prevent musty smells.',
    Icons.ac_unit_rounded,
    AppColors.purple,
  ),
];

const List<String> chatQuickReplies = [
  'How long will you take?',
  'Please bring the right tools',
  'I am at the main gate',
  'Share your live location',
];

const List<PaymentMethod> paymentMethods = [
  PaymentMethod.bkash,
  PaymentMethod.nagad,
  PaymentMethod.rocket,
  PaymentMethod.cash,
];

List<BookingRecord> seedHistory() {
  final now = DateTime.now();
  return [
    BookingRecord(
      id: 'seed-1',
      title: 'Brake pad replacement',
      vehicle: 'Toyota Corolla',
      mechanicName: 'Rahim Uddin',
      date: now.subtract(const Duration(days: 3, hours: 2)),
      travelFee: 95,
      status: BookingStatus.paid,
      method: PaymentMethod.bkash,
      txn: 'CRD72841930',
      lines: [
        BillLine(
          serviceId: 'car-brake',
          name: 'Brake Pad Replacement',
          amount: 2750,
        ),
        BillLine(
          serviceId: 'car-diagnostics',
          name: 'Engine Diagnostics',
          amount: 1220,
        ),
      ],
    ),
    BookingRecord(
      id: 'seed-2',
      title: 'Full bike servicing',
      vehicle: 'Yamaha FZS',
      mechanicName: 'Kabir Hossain',
      date: now.subtract(const Duration(days: 12, hours: 5)),
      travelFee: 75,
      status: BookingStatus.paid,
      method: PaymentMethod.cash,
      txn: 'CRD55102847',
      lines: [
        BillLine(
          serviceId: 'bike-service',
          name: 'Full Servicing',
          amount: 1395,
        ),
        BillLine(
          serviceId: 'bike-oil',
          name: 'Engine Oil Change',
          amount: 545,
        ),
      ],
    ),
  ];
}
