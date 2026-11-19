import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

enum PaymentMethod { bkash, nagad, rocket, cash }

extension PaymentMethodX on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.bkash:
        return 'bKash';
      case PaymentMethod.nagad:
        return 'Nagad';
      case PaymentMethod.rocket:
        return 'Rocket';
      case PaymentMethod.cash:
        return 'Cash';
    }
  }

  String get subtitle {
    switch (this) {
      case PaymentMethod.bkash:
        return 'Dial *247# · Pay securely';
      case PaymentMethod.nagad:
        return 'Dial *167# · Instant pay';
      case PaymentMethod.rocket:
        return 'Dial *322# · Pay securely';
      case PaymentMethod.cash:
        return 'Pay the mechanic directly';
    }
  }

  Color get color {
    switch (this) {
      case PaymentMethod.bkash:
        return AppColors.bkash;
      case PaymentMethod.nagad:
        return AppColors.nagad;
      case PaymentMethod.rocket:
        return AppColors.rocket;
      case PaymentMethod.cash:
        return AppColors.cash;
    }
  }

  Color get softColor => color.withOpacity(0.10);

  String get badge {
    switch (this) {
      case PaymentMethod.bkash:
        return 'bKash';
      case PaymentMethod.nagad:
        return 'Nagad';
      case PaymentMethod.rocket:
        return 'Rocket';
      case PaymentMethod.cash:
        return 'Cash';
    }
  }
}
