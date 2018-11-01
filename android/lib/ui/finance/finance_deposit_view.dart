import 'dart:ui';

import 'package:android/model/deposit.dart';
import 'package:flutter/material.dart';

Color getColorForDeposit(FinanceDeposit deposit){
  if(deposit.type == FinanceDepositType.bankAccount){
    if(deposit.balance > 500) {
      return Colors.lightGreen;
    } else {
      return Colors.red;
    }
  }

  if(deposit.balance > 30) {
    return Colors.lightGreen;
  } else {
    return Colors.red;
  }
}