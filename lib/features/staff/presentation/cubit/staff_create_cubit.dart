import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/events/data_refresh_bus.dart';
import '../../data/staff_models.dart';
import '../../data/staff_repository.dart';

class StaffCreateState extends Equatable {
  const StaffCreateState({
    this.step = 0,
    this.phone = '',
    this.verifyToken,
    this.permissionGroups = const [],
    this.selectedPermissions = const {},
    this.isLoading = false,
    this.error,
    this.success = false,
  });

  final int step;
  final String phone;
  final String? verifyToken;
  final List<PermissionGroup> permissionGroups;
  final Set<String> selectedPermissions;
  final bool isLoading;
  final Failure? error;
  final bool success;

  StaffCreateState copyWith({
    int? step,
    String? phone,
    String? verifyToken,
    List<PermissionGroup>? permissionGroups,
    Set<String>? selectedPermissions,
    bool? isLoading,
    Failure? error,
    bool clearError = false,
    bool? success,
  }) {
    return StaffCreateState(
      step: step ?? this.step,
      phone: phone ?? this.phone,
      verifyToken: verifyToken ?? this.verifyToken,
      permissionGroups: permissionGroups ?? this.permissionGroups,
      selectedPermissions: selectedPermissions ?? this.selectedPermissions,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      success: success ?? this.success,
    );
  }

  @override
  List<Object?> get props => [step, phone, verifyToken, permissionGroups, selectedPermissions, isLoading, error, success];
}

/// Xodim qo'shish — 3 qadam (MOBILE_APP_TZ.md 15.1).
class StaffCreateCubit extends Cubit<StaffCreateState> {
  StaffCreateCubit(this._repository) : super(const StaffCreateState());

  final StaffRepository _repository;

  Future<void> loadPermissionGroups() async {
    final result = await _repository.getPermissionGroups();
    result.when(success: (groups) => emit(state.copyWith(permissionGroups: groups)), failure: (_) {});
  }

  Future<void> submitPhone(String phone) async {
    emit(state.copyWith(isLoading: true, clearError: true, phone: phone));
    final result = await _repository.sendOtp(phone);
    result.when(
      success: (_) => emit(state.copyWith(isLoading: false, step: 1)),
      failure: (f) => emit(state.copyWith(isLoading: false, error: f)),
    );
  }

  Future<void> submitOtp(String code) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    final result = await _repository.verifyOtp(phone: state.phone, otpCode: code);
    result.when(
      success: (token) => emit(state.copyWith(isLoading: false, step: 2, verifyToken: token)),
      failure: (f) => emit(state.copyWith(isLoading: false, error: f)),
    );
  }

  void togglePermission(String key) {
    final updated = Set.of(state.selectedPermissions);
    if (updated.contains(key)) {
      updated.remove(key);
    } else {
      updated.add(key);
    }
    emit(state.copyWith(selectedPermissions: updated));
  }

  void toggleAllInCategory(PermissionGroup group, bool selectAll) {
    final updated = Set.of(state.selectedPermissions);
    for (final item in group.items) {
      if (selectAll) {
        updated.add(item.key);
      } else {
        updated.remove(item.key);
      }
    }
    emit(state.copyWith(selectedPermissions: updated));
  }

  Future<void> submitDetails({required String name, required String password}) async {
    if (state.selectedPermissions.isEmpty) {
      emit(state.copyWith(error: const BusinessFailure('Kamida 1 ta ruxsat tanlanishi kerak')));
      return;
    }
    emit(state.copyWith(isLoading: true, clearError: true));
    final result = await _repository.createStaff(
      phone: state.phone,
      verifyToken: state.verifyToken ?? '',
      name: name,
      password: password,
      permissions: state.selectedPermissions.toList(),
    );
    result.when(
      success: (_) {
        getIt<DataRefreshBus>().notifyStaffChanged();
        emit(state.copyWith(isLoading: false, success: true));
      },
      failure: (f) => emit(state.copyWith(isLoading: false, error: f)),
    );
  }
}
