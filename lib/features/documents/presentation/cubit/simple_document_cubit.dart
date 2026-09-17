import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../data/document_models.dart';

sealed class SimpleDocumentState extends Equatable {
  const SimpleDocumentState();
  @override
  List<Object?> get props => [];
}

class SimpleDocumentLoading extends SimpleDocumentState {
  const SimpleDocumentLoading();
}

class SimpleDocumentLoaded extends SimpleDocumentState {
  const SimpleDocumentLoaded(this.items);
  final List<SimpleDocument> items;
  @override
  List<Object?> get props => [items];
}

class SimpleDocumentError extends SimpleDocumentState {
  const SimpleDocumentError(this.failure);
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}

/// Ish turlari / Lavozimlar kabi `name`+`description` ma'lumotnomalari uchun
/// umumiy CRUD kontroller (MOBILE_APP_TZ.md 11-bo'lim).
class SimpleDocumentCubit extends Cubit<SimpleDocumentState> {
  SimpleDocumentCubit({
    required this.fetchAll,
    required this.create,
    required this.update,
    required this.delete,
    required this.restore,
  }) : super(const SimpleDocumentLoading());

  final Future<dynamic> Function() fetchAll;
  final Future<dynamic> Function(String name, String? description) create;
  final Future<dynamic> Function(int id, String name, String? description) update;
  final Future<dynamic> Function(int id) delete;
  final Future<dynamic> Function(int id) restore;

  Future<void> load() async {
    emit(const SimpleDocumentLoading());
    final result = await fetchAll();
    result.when(
      success: (items) => emit(SimpleDocumentLoaded(items as List<SimpleDocument>)),
      failure: (f) => emit(SimpleDocumentError(f as Failure)),
    );
  }

  Future<Failure?> submitCreate(String name, String? description) async {
    final result = await create(name, description);
    return result.when(success: (_) { load(); return null; }, failure: (f) => f as Failure);
  }

  Future<Failure?> submitUpdate(int id, String name, String? description) async {
    final result = await update(id, name, description);
    return result.when(success: (_) { load(); return null; }, failure: (f) => f as Failure);
  }

  Future<Failure?> submitDelete(int id) async {
    final result = await delete(id);
    return result.when(success: (_) { load(); return null; }, failure: (f) => f as Failure);
  }

  Future<Failure?> submitRestore(int id) async {
    final result = await restore(id);
    return result.when(success: (_) { load(); return null; }, failure: (f) => f as Failure);
  }
}
