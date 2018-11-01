import 'package:android/model/finance_transaction.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FinanceTransactionStateView {
  static Map<FinanceTransactionState, FinanceTransactionStateView> _map;

  final FinanceTransactionState state;
  final String label;
  final IconData icon;
  final Color color;

  FinanceTransactionStateView(this.state, this.label, this.icon, this.color);

  static Map<FinanceTransactionState, FinanceTransactionStateView> getMap() {
    if (_map == null) {
      _map = Map<FinanceTransactionState, FinanceTransactionStateView>();
      _map[FinanceTransactionState.executed] = FinanceTransactionStateView(
        FinanceTransactionState.executed,
        'Executed',
        Icons.done,
        Colors.green,
      );
      _map[FinanceTransactionState.cancelled] = FinanceTransactionStateView(
        FinanceTransactionState.cancelled,
        'Cancelled',
        Icons.clear,
        Colors.red,
      );
      _map[FinanceTransactionState.blocked] = FinanceTransactionStateView(
        FinanceTransactionState.blocked,
        'Blocked',
        Icons.block,
        Colors.orange,
      );
      _map[FinanceTransactionState.planned] = FinanceTransactionStateView(
        FinanceTransactionState.planned,
        'Planned',
        Icons.calendar_today,
        Colors.white,
      );
    }
    return _map;
  }
}
