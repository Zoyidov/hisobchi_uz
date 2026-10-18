import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/domain/entities/app_file.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/events/data_refresh_bus.dart';
import '../../data/installment_models.dart';
import '../../data/installment_scheduler.dart';
import '../../data/installments_repository.dart';

class InstallmentCreateState extends Equatable {
  const InstallmentCreateState({
    this.step = 0,
    this.currencyTypeId = 1,
    this.totalAmount,
    this.note = '',
    this.fileIds = const [],
    this.files = const [],
    this.isUploading = false,
    this.scheduleType = InstallmentScheduleType.equal,
    this.hasAdvance = false,
    this.advanceAmount,
    this.startDate,
    this.installmentCount = 4,
    this.customItems = const [],
    this.isSubmitting = false,
    this.submitError,
    this.createdPlan,
  });

  final int step;
  final int currencyTypeId;
  final Decimal? totalAmount;
  final String note;
  final List<int> fileIds;
  final List<AppFile> files;
  final bool isUploading;
  final InstallmentScheduleType scheduleType;
  final bool hasAdvance;
  final Decimal? advanceAmount;
  final DateTime? startDate;
  final int installmentCount;
  final List<InstallmentPreviewItem> customItems;
  final bool isSubmitting;
  final Failure? submitError;
  final InstallmentPlan? createdPlan;

  List<InstallmentPreviewItem> get preview {
    if (totalAmount == null) return const [];
    if (scheduleType == InstallmentScheduleType.custom) {
      return [
        if (hasAdvance && advanceAmount != null)
          InstallmentPreviewItem(
            itemNumber: 0,
            amount: advanceAmount!,
            dueDate: startDate ?? DateTime.now(),
            isAdvance: true,
          ),
        for (var i = 0; i < customItems.length; i++)
          InstallmentPreviewItem(
            itemNumber: i + 1,
            amount: customItems[i].amount,
            dueDate: customItems[i].dueDate,
            isAdvance: false,
            note: customItems[i].note,
          ),
      ];
    }
    return InstallmentScheduler.generateEqualSchedule(
      totalAmount: totalAmount!,
      hasAdvance: hasAdvance,
      advanceAmount: hasAdvance ? advanceAmount : null,
      startDate: startDate ?? DateTime.now(),
      installmentCount: installmentCount,
    );
  }

  /// AC-9.3, 9.4 validatsiya qoidalari.
  String? get step2ValidationError {
    if (totalAmount == null || totalAmount! <= Decimal.zero) {
      return 'Jami summa 0 dan katta bo\'lishi kerak.';
    }
    if (hasAdvance &&
        (advanceAmount == null ||
            advanceAmount! <= Decimal.zero ||
            advanceAmount! >= totalAmount!)) {
      return 'Avans summasi jami summadan kichik bo\'lishi kerak.';
    }
    if (scheduleType == InstallmentScheduleType.equal) {
      final minCount = hasAdvance ? 1 : 2;
      if (installmentCount < minCount) {
        return hasAdvance
            ? 'Avans bilan kamida 1 ta qism bo\'lishi kerak.'
            : 'Avanssiz kamida 2 ta qism bo\'lishi kerak.';
      }
      if ((startDate ?? DateTime.now()).isBefore(
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
      )) {
        return 'Boshlanish sanasi bugundan kichik bo\'lishi mumkin emas.';
      }
    } else {
      if (customItems.any((i) => i.amount <= Decimal.zero)) {
        return 'Har bir qism summasi 0 dan katta bo‘lishi kerak.';
      }
      if (customItems.length < (hasAdvance ? 1 : 2)) {
        return hasAdvance
            ? 'Avans bilan kamida 1 ta qism kiritilishi kerak.'
            : 'Kamida 2 ta qism kiritilishi kerak.';
      }
      final sum = customItems.fold(Decimal.zero, (acc, i) => acc + i.amount);
      final expected = hasAdvance
          ? totalAmount! - (advanceAmount ?? Decimal.zero)
          : totalAmount!;
      if (sum != expected) {
        return 'Qismlar yig\'indisi jami summaga teng bo\'lishi kerak.';
      }
      final today = DateTime.now();
      final hasPastDate = customItems.any(
        (i) => i.dueDate.isBefore(DateTime(today.year, today.month, today.day)),
      );
      if (hasPastDate) {
        return 'To\'lov sanasi bugundan kichik bo\'lishi mumkin emas.';
      }
    }
    if (preview.any((i) => i.amount <= Decimal.zero)) {
      return 'Har bir qism summasi 0 dan katta bo‘lishi kerak.';
    }
    return null;
  }

  InstallmentCreateState copyWith({
    int? step,
    int? currencyTypeId,
    Decimal? totalAmount,
    bool clearTotal = false,
    List<AppFile>? files,
    bool? isUploading,
    String? note,
    List<int>? fileIds,
    InstallmentScheduleType? scheduleType,
    bool? hasAdvance,
    Decimal? advanceAmount,
    bool clearAdvance = false,
    DateTime? startDate,
    int? installmentCount,
    List<InstallmentPreviewItem>? customItems,
    bool? isSubmitting,
    Failure? submitError,
    bool clearError = false,
    InstallmentPlan? createdPlan,
  }) {
    return InstallmentCreateState(
      step: step ?? this.step,
      currencyTypeId: currencyTypeId ?? this.currencyTypeId,
      totalAmount: clearTotal ? null : totalAmount ?? this.totalAmount,
      files: files ?? this.files,
      isUploading: isUploading ?? this.isUploading,
      note: note ?? this.note,
      fileIds: fileIds ?? this.fileIds,
      scheduleType: scheduleType ?? this.scheduleType,
      hasAdvance: hasAdvance ?? this.hasAdvance,
      advanceAmount: clearAdvance
          ? null
          : (advanceAmount ?? this.advanceAmount),
      startDate: startDate ?? this.startDate,
      installmentCount: installmentCount ?? this.installmentCount,
      customItems: customItems ?? this.customItems,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: clearError ? null : (submitError ?? this.submitError),
      createdPlan: createdPlan ?? this.createdPlan,
    );
  }

  @override
  List<Object?> get props => [
    step,
    currencyTypeId,
    totalAmount,
    note,
    fileIds,
    files,
    isUploading,
    scheduleType,
    hasAdvance,
    advanceAmount,
    startDate,
    installmentCount,
    customItems,
    isSubmitting,
    submitError,
    createdPlan,
  ];
}

/// Reja yaratish wizard'i — 3 qadam (MOBILE_APP_TZ.md 9.4).
class InstallmentCreateCubit extends Cubit<InstallmentCreateState> {
  InstallmentCreateCubit(
    this._repository, {
    required this.partnerId,
    required int currencyTypeId,
  }) : super(
         InstallmentCreateState(
           currencyTypeId: currencyTypeId,
           startDate: DateTime.now(),
         ),
       );

  final InstallmentsRepository _repository;
  final int partnerId;

  void setCurrency(int id) => emit(state.copyWith(currencyTypeId: id));
  void setTotalAmount(Decimal? amount) =>
      emit(state.copyWith(totalAmount: amount, clearTotal: amount == null));
  void setFiles(List<AppFile> files) => emit(
    state.copyWith(
      files: List.unmodifiable(files),
      fileIds: files.map((f) => f.id).toList(),
    ),
  );
  void setUploading(bool value) => emit(state.copyWith(isUploading: value));
  void setNote(String note) => emit(state.copyWith(note: note));
  void setFileIds(List<int> ids) => emit(state.copyWith(fileIds: ids));
  void setScheduleType(InstallmentScheduleType type) =>
      emit(state.copyWith(scheduleType: type));
  void setHasAdvance(bool value) =>
      emit(state.copyWith(hasAdvance: value, clearAdvance: !value));
  void setAdvanceAmount(Decimal? amount) =>
      emit(state.copyWith(advanceAmount: amount, clearAdvance: amount == null));
  void setStartDate(DateTime date) => emit(state.copyWith(startDate: date));
  void setInstallmentCount(int count) =>
      emit(state.copyWith(installmentCount: count.clamp(1, 60)));
  void setCustomItems(List<InstallmentPreviewItem> items) =>
      emit(state.copyWith(customItems: items));

  void goToStep(int step) => emit(state.copyWith(step: step, clearError: true));
  void nextStep() {
    if (state.isSubmitting || state.isUploading) return;
    if (state.step == 0 &&
        (state.totalAmount == null || state.totalAmount! <= Decimal.zero)) {
      return;
    }
    emit(state.copyWith(step: (state.step + 1).clamp(0, 2), clearError: true));
  }

  void previousStep() =>
      emit(state.copyWith(step: (state.step - 1).clamp(0, 2)));

  Future<void> submit() async {
    if (state.isSubmitting || state.createdPlan != null) return;
    final error = state.isUploading
        ? 'Fayllar yuklanishini kuting.'
        : state.step2ValidationError;
    if (error != null) {
      emit(state.copyWith(submitError: BusinessFailure(error)));
      return;
    }
    emit(state.copyWith(isSubmitting: true, clearError: true));
    final result = state.scheduleType == InstallmentScheduleType.equal
        ? await _repository.createEqual(
            partnerId: partnerId,
            currencyTypeId: state.currencyTypeId,
            totalAmount: state.totalAmount!,
            hasAdvance: state.hasAdvance,
            advanceAmount: state.hasAdvance ? state.advanceAmount : null,
            startDate: state.startDate ?? DateTime.now(),
            installmentCount: state.installmentCount,
            note: state.note,
            fileIds: state.fileIds.isEmpty ? null : state.fileIds,
          )
        : await _repository.createCustom(
            partnerId: partnerId,
            currencyTypeId: state.currencyTypeId,
            totalAmount: state.totalAmount!,
            hasAdvance: state.hasAdvance,
            advanceAmount: state.hasAdvance ? state.advanceAmount : null,
            items: state.customItems,
            note: state.note,
            fileIds: state.fileIds.isEmpty ? null : state.fileIds,
          );
    result.when(
      success: (plan) {
        getIt<DataRefreshBus>().notifyInstallmentsChanged(
          installmentId: plan.id,
        );
        getIt<DataRefreshBus>().notifyWalletsChanged(partnerId: partnerId);
        if (isClosed) return;
        emit(state.copyWith(isSubmitting: false, createdPlan: plan));
      },
      failure: (f) {
        if (isClosed) return;
        emit(state.copyWith(isSubmitting: false, submitError: f));
      },
    );
  }
}
