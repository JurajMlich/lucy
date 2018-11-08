import 'dart:ui';

import 'package:android/config/config.dart';
import 'package:android/model/finance_deposit.dart';
import 'package:android/model/finance_transaction.dart';
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

String formatTransactionValue(FinanceTransaction transaction) {
  String result = '';
  if (transaction.sourceDepositId == null) {
    result += '+';
  } else if (transaction.targetDepositId == null) {
    result += '-';
  }

  return result + Config.currencyFormat.format(transaction.value);
}

Color getColorForTransaction(FinanceTransaction transaction) {
  if (transaction.sourceDepositId == null) {
    return Colors.green;
  } else if (transaction.targetDepositId == null) {
    return Colors.red;
  }

  return null;
}
