class DashboardInitializeAction {}
class DashboardDisposeAction {}

class DashboardInitializedAction {
  final double todaySpent;
  final double todayMax;
  final double balance;

  DashboardInitializedAction(this.todaySpent, this.todayMax, this.balance);
}
