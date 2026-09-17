import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/entities/user_entity.dart';
import '../domain/repositories/auth_repository.dart';
import '../errors/failure.dart';

sealed class UserState extends Equatable {
  const UserState();
  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {
  const UserInitial();
}

class UserLoading extends UserState {
  const UserLoading();
}

class UserLoaded extends UserState {
  const UserLoaded(this.user);
  final UserEntity user;
  @override
  List<Object?> get props => [user];
}

class UserError extends UserState {
  const UserError(this.failure);
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}

/// `me()` natijasi — profil, rollar, ruxsatlar manbai (MOBILE_APP_TZ.md 6.1).
/// Ilova ishga tushganda va foreground'ga qaytganda qayta yuklanadi.
class UserCubit extends Cubit<UserState> {
  UserCubit(this._authRepository) : super(const UserInitial());

  final AuthRepository _authRepository;

  UserEntity? get currentUserOrNull {
    final s = state;
    return s is UserLoaded ? s.user : null;
  }

  Future<void> loadMe() async {
    emit(const UserLoading());
    final result = await _authRepository.me();
    result.when(
      success: (user) => emit(UserLoaded(user)),
      failure: (failure) => emit(UserError(failure)),
    );
  }

  void clear() => emit(const UserInitial());
}
