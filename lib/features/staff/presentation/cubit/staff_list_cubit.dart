import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../data/staff_models.dart';
import '../../data/staff_repository.dart';

sealed class StaffListState extends Equatable {
  const StaffListState();
  @override
  List<Object?> get props => [];
}

class StaffListLoading extends StaffListState {
  const StaffListLoading();
}

class StaffListLoaded extends StaffListState {
  const StaffListLoaded(this.items);
  final List<StaffMember> items;
  @override
  List<Object?> get props => [items];
}

class StaffListError extends StaffListState {
  const StaffListError(this.failure);
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}

/// Xodimlar ro'yxati (MOBILE_APP_TZ.md 15.2).
class StaffListCubit extends Cubit<StaffListState> {
  StaffListCubit(this._repository) : super(const StaffListLoading());

  final StaffRepository _repository;

  Future<void> load() async {
    emit(const StaffListLoading());
    final result = await _repository.getStaff();
    result.when(success: (items) => emit(StaffListLoaded(items)), failure: (f) => emit(StaffListError(f)));
  }

  Future<Failure?> toggleActive(StaffMember staff) async {
    final result = await _repository.updateStaff(staff.id, permissions: staff.permissions, isActive: !staff.isActive);
    return result.when(success: (_) { load(); return null; }, failure: (f) => f);
  }

  Future<Failure?> delete(int id) async {
    final result = await _repository.deleteStaff(id);
    return result.when(success: (_) { load(); return null; }, failure: (f) => f);
  }
}
