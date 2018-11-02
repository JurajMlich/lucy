import 'dart:ui';

import 'package:android/model/finance_deposit.dart';
import 'package:flutter/material.dart';

Color getColorForDeposit(FinanceDeposit deposit) {
  if (deposit.minBalance == null) {
    return null;
  }

  if (deposit.balance >= deposit.minBalance) {
    return Colors.lightGreen;
  } else {
    return Colors.red;
  }
}
