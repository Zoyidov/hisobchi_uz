import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../storage/secure_storage_service.dart';

/// Xodim qaysi owner nomidan ishlayotgani (MOBILE_APP_TZ.md 6.2–6.3).
/// `null` — foydalanuvchi o'z hisobida ishlayapti.
class OwnerContext extends Equatable {
  const OwnerContext({this.ownerId, this.ownerName});

  final int? ownerId;
  final String? ownerName;

  bool get isStaffMode => ownerId != null;

  static const own = OwnerContext();

  @override
  List<Object?> get props => [ownerId, ownerName];
}

class OwnerContextCubit extends Cubit<OwnerContext> {
  OwnerContextCubit(this._secureStorage) : super(OwnerContext.own);

  final SecureStorageService _secureStorage;

  Future<void> restore() async {
    final saved = await _secureStorage.readOwnerContext();
    if (saved != null) {
      final id = int.tryParse(saved);
      if (id != null) emit(OwnerContext(ownerId: id));
    }
  }

  Future<void> switchTo(OwnerContext context) async {
    emit(context);
    if (context.ownerId != null) {
      await _secureStorage.saveOwnerContext(context.ownerId.toString());
    } else {
      await _secureStorage.clearOwnerContext();
    }
  }

  Future<void> reset() async {
    emit(OwnerContext.own);
    await _secureStorage.clearOwnerContext();
  }
}
