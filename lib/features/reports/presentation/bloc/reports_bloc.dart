import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/reports_repository.dart';
import 'reports_event.dart';
import 'reports_state.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final ReportsRepository _repository;

  ReportsBloc(this._repository) : super(const ReportsState()) {
    on<LoadReports>(_onLoadReports);
    on<LoadRevenueReport>(_onLoadRevenueReport);
  }

  Future<void> _onLoadReports(LoadReports event, Emitter<ReportsState> emit) async {
    emit(state.copyWith(status: ReportsStatus.loading));
    try {
      final inventoryItems = await _repository.getInventoryReport();
      final totalInventoryValue = await _repository.getTotalInventoryValue();
      
      // Default revenue for this month
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, 1);
      final endDate = DateTime(now.year, now.month + 1, 0); // End of month
      
      final revenueItems = await _repository.getRevenueReport(startDate: startDate, endDate: endDate);
      final totalRevenue = await _repository.getTotalRevenue(startDate: startDate, endDate: endDate);

      emit(state.copyWith(
        status: ReportsStatus.success,
        inventoryItems: inventoryItems,
        totalInventoryValue: totalInventoryValue,
        revenueItems: revenueItems,
        totalRevenue: totalRevenue,
        revenueStartDate: startDate,
        revenueEndDate: endDate,
      ));
    } catch (e) {
      emit(state.copyWith(status: ReportsStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadRevenueReport(LoadRevenueReport event, Emitter<ReportsState> emit) async {
     emit(state.copyWith(status: ReportsStatus.loading));
     try {
       final revenueItems = await _repository.getRevenueReport(startDate: event.startDate, endDate: event.endDate);
       final totalRevenue = await _repository.getTotalRevenue(startDate: event.startDate, endDate: event.endDate);
       
       emit(state.copyWith(
         status: ReportsStatus.success,
         revenueItems: revenueItems,
         totalRevenue: totalRevenue,
         revenueStartDate: event.startDate,
         revenueEndDate: event.endDate
       ));
     } catch (e) { 
        emit(state.copyWith(status: ReportsStatus.failure, errorMessage: e.toString()));
     }
  }
}
