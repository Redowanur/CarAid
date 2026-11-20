<p align="center">
  <img src="docs/logo.jpeg" alt="CarAid logo" width="180" />
</p>

<h1 align="center">CarAid</h1>

<p align="center">
  On-demand roadside assistance, powered by Flutter.
</p>

CarAid is an on-demand roadside-assistance marketplace built with Flutter. It connects drivers who need help with verified mechanics who can arrive on site, perform the repair, and issue an itemized digital bill. The app is designed around a Dhaka demo scenario: English UI, BDT (`৳`) pricing, local payment brands, and Google Maps centred on Gulshan 2.

The project is a **single Flutter app with two roles** — Customer and Mechanic — plus a set of free tools that remain available without a subscription. Authentication uses Firebase, while the booking, tracking, billing, and subscription journeys are simulated locally so the whole experience works offline on one phone.

---

## Features

### Customer
- **On-demand booking** — pick a vehicle (car, bike, CNG, truck), choose one or more services, compare nearby mechanics by rating, distance, and ETA, then review a transparent estimate before confirming.
- **Live tracking** — a Google Map with customer/mechanic markers, a dashed route line, simulated mechanic movement toward the customer, progress bar, and a live ETA. A "skip to arrival" shortcut supports one-phone demos.
- **Chat and call** — seeded conversation with the assigned mechanic plus simulated replies; phone/telephone links are premium-gated.
- **Mechanic-verified checklist** — the mechanic ticks the services actually completed; the customer reviews the same checklist and confirms the final line items.
- **Itemized digital bill** — service lines, travel fee (`৳60` base + `৳18/km`), platform fee (`৳0`), and grand total, all in BDT.
- **Simulated checkout** — bKash, Nagad, Rocket, or Cash, with a processing state, generated transaction ID, receipt screen, and service history.
- **Service history and profile** — past jobs with payment method, transaction ID, travel fee, and totals; profile with plan status and sign-out.

### Mechanic
- **Dashboard** — online/offline toggle, today's earnings, jobs count, weekly and monthly totals, active job card, quick actions, and premium upsell.
- **Job requests** — nearby requests with customer, area, vehicle, reported problem, distance, urgency badge, payout, and accept/decline actions.
- **Service checklist** — mark completed services, add travel distance and notes, generate the bill, and credit earnings.
- **Earnings** — available balance, week/month totals, payout history with payment method and transaction IDs, and a simulated withdraw action.
- **Garage profile** — verified badge, subscription state, garage details, support info, and sign-out.

### Free tools (no subscription required)
- Full **service price chart** with price ranges and durations across all vehicle types.
- **Repair cost estimator** with vehicle, service, and distance sliders plus a live BDT breakdown.
- **Browse nearby mechanics** with search, specialty filters, distance sorting, and detail pages.
- **Maintenance tips** with localized advice for Dhaka driving conditions.
- **Emergency contacts** sheet (ambulance, fire service, police, CarAid support).

### Subscriptions (mocked)
- 7-day free trial for both roles, then monthly/yearly plans:
  - Customer: `৳199/month`, `৳1,999/year`
  - Mechanic: `৳299/month`, `৳2,999/year`
- Role-specific plan comparison, checkout simulation, plan state in `AppState`, and best-effort persistence to Firestore.
- Premium gates live tracking, chat/call, on-demand booking, cashless payment, itemized billing, and priority placement. Free tools are never gated.

### Platform
- Firebase Authentication (email/password) and Firestore profile/persistence helpers.
- Demo login bypasses Firebase so the full app can be explored offline.
- Location via `geolocator` with a graceful fallback to the demo coordinates.
- Material 3 light theme with navy/teal/amber tokens, UberMove display font, and consistent shared widgets (buttons, cards, nav bar, status pills, avatars, logo, paywall sheet).

---

## Architecture

| Layer | Location | Responsibility |
| --- | --- | --- |
| Entry | `lib/main.dart`, `lib/car_aid_app.dart` | Firebase init (non-fatal), `MaterialApp`, theme, text-scale clamp, splash route |
| State | `lib/state/app_state.dart` | Single `ChangeNotifier` holding session, subscriptions, booking journey, tracking, chat, and mechanic workspace |
| Models | `lib/models/` | `BookingRecord`, `JobRequest`, `ChatMessage`, `SubscriptionPlan`, `BillLine`, `ServiceEntry`, `MechanicPro`, `VehicleType`, `PaymentMethod`, `UserProfile` |
| Data | `lib/data/demo_data.dart` | Seed mechanics, services, plans, requests, tips, history, payouts, and pricing helpers |
| Services | `lib/core/services/` | Firebase auth/profile/booking/subscription persistence; device location |
| Utilities | `lib/core/utils/` | BDT/date/duration formatting, haversine distance, travel fee, route interpolation, snack bars, routes |
| Theme | `lib/core/theme/app_theme.dart` | Colour tokens, gradients, typography, `ThemeData` |
| Shared widgets | `lib/widgets/` | Buttons, cards, bottom nav, logo, paywall sheet |
| Screens | `lib/screens/` | Auth, customer shell/tabs/journey, mechanic shell/tabs, shared screens |
| Legacy screens | `lib/Customer/`, `lib/Mechanic/`, `lib/Admin/`, and root-level legacy Dart files | Original prototype, kept intact and compiling |

Navigation is imperative with a shared `riseRoute` transition. Shells use `IndexedStack` with `AppBottomNav`, and screens rebuild from `appState` via `AnimatedBuilder`. Firebase failures are swallowed on initialization and during writes so the demo remains usable without network access.

---

## Project structure

```text
lib/
  main.dart                    # App entry: Firebase init + CarAidApp
  car_aid_app.dart             # MaterialApp / theme / splash
  state/app_state.dart         # Global ChangeNotifier (single source of truth)
  core/
    services/                  # firebase_service.dart, location_service.dart
    theme/app_theme.dart       # Design tokens and ThemeData
    utils/                     # formatters, geo, ui helpers
  data/demo_data.dart          # All seeded demo content and pricing
  models/                      # Domain models and enums
  widgets/                     # Shared UI components
  screens/
    splash_screen.dart
    auth_screen.dart
    signup_screen.dart
    customer/                  # Shell, tabs, booking → tracking → checklist → bill → payment
    mechanic/                  # Shell, dashboard, requests, earnings, profile
    shared/                    # Mechanic detail, price chart, estimator, tips, chat, subscriptions
  Customer/ Mechanic/ Admin/   # Legacy prototype screens (retained)
test/
  widget_test.dart             # App boot smoke test
  app_state_test.dart          # Auth, subscription, billing, and mechanic workspace logic
  shell_test.dart              # Customer and mechanic tab rendering/navigation
android/
  app/google-services.json     # Firebase config for database-project-d08b5
  app/src/main/res/            # Launcher icons (all densities + adaptive) and app_name
```

---

## Getting started

### Prerequisites
- Flutter **3.10.6** (Dart 3.0.6). The repo pins this version in `.fvmrc`; using FVM is recommended:
  ```bash
  fvm install
  ```
- Android SDK with **compileSdk 34** / Build-Tools 34 and a JDK compatible with Gradle 7.3.
- A connected device or emulator. Maps and location behave best on a real device with Google Play services.

### Install and run
```bash
fvm flutter pub get
fvm flutter run
```

### Firebase and Maps
- `android/app/google-services.json` is committed for the `database-project-d08b5` Firebase project. Replace it to point at your own project.
- `Firebase.initializeApp()` runs in a `try/catch`; sign-in and persistence are skipped gracefully when Firebase is unavailable.
- The Google Maps key is configured in `android/app/src/main/AndroidManifest.xml` under `com.google.android.geo.API_KEY`. Replace it with your own key for a new project.
- The Android build substitutes the unavailable `me.carda:AndroidAwnCore` artifact with the public JitPack coordinate `com.github.rafaelsetragni:AndroidAwnCore:0.8.3` (see `android/build.gradle`). Do not remove this substitution or builds will fail with a JitPack `401`.

### Try the demo
1. Open the app. From the auth screen choose **Explore as Customer** or **Explore as Mechanic** — no credentials needed.
2. Customer: **Find a mechanic** → choose services → pick a mechanic → **Review booking** → **Confirm & track**. The first premium action opens the paywall; choose **Start 7-day free trial**. Then use **Skip to arrival**, open the checklist, generate the bill, and pay with any simulated method.
3. Mechanic: open **Requests**, accept a job (start the trial if prompted), open the checklist, tick completed services, generate the bill, then check **Earnings** for the payout record.
4. Free tools are on the customer home screen: price chart, cost estimate, care tips, and emergency contacts.

---

## Testing and verification

```bash
fvm flutter analyze          # 0 errors, 0 warnings
fvm flutter test             # 14 tests
fvm flutter build apk --debug
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

The debug APK is produced at `build/app/outputs/flutter-apk/app-debug.apk`. The tests cover app boot, demo/subscription/billing state transitions, both shells, tab navigation, and the payment-travel-fee formula. The complete customer and mechanic journeys were also exercised on a physical Pixel 6.

---

## Design notes

- **Palette:** navy `#0D1B2A`, teal `#11B39A`, amber `#FFB020`, with soft neutral surfaces and role/payment accent colours.
- **Typography:** UberMove display font (bundled in `fonts/`) with a readable body style and a clamped text scale (0.9–1.15).
- **Money:** all prices are integers in BDT and formatted through `lib/core/utils/formatters.dart` (e.g. `৳2,090`).
- **Travel pricing:** `৳60` base + `৳18/km`, derived from haversine distance between demo or device coordinates.
- **Logo:** supplied brand image at `assets/logo.jpeg`, also used to generate launcher icons at every Android density.

---

## Notes and limitations

- Payments, subscriptions, chat replies, and mechanic movement are **simulations**. No real money moves and no payment-gateway credentials are required.
- Firebase writes are best-effort: the UI never blocks on Firestore availability.
- The Google Maps key and Firebase config in this repository are demo values; replace them before publishing.
- On Android 17 devices with 16 KB pages, a one-time system `PageSizeMismatchDialog` warning may appear at launch; dismissing it does not affect the app.
- Legacy prototype screens are retained for reference. New work should continue under `lib/screens/`, `lib/state/`, and `lib/widgets/`.
