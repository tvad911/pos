abstract class ReportsEvent {}

class LoadReports extends ReportsEvent {}

class LoadRevenueReport extends ReportsEvent {
  final DateTime startDate;
  final DateTime endDate;
  LoadRevenueReport(this.startDate, this.endDate);
}
