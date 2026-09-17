import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../cubits/auth_cubit.dart';
import '../cubits/connectivity_cubit.dart';
import '../cubits/owner_context_cubit.dart';
import '../cubits/subscription_cubit.dart';
import '../cubits/user_cubit.dart';
import '../domain/repositories/auth_repository.dart';
import '../localization/locale_cubit.dart';
import '../network/api_client.dart';
import '../network/auth_session_controller.dart';
import '../network/dio_client.dart';
import '../network/interceptors/auth_interceptor.dart';
import '../network/interceptors/error_interceptor.dart';
import '../network/interceptors/logging_interceptor.dart';
import '../services/device_info_service.dart';
import '../services/file_upload_service.dart';
import '../storage/local_cache_service.dart';
import '../storage/secure_storage_service.dart';
import '../theme/theme_cubit.dart';
import '../../features/auth/data/auth_remote_data_source.dart';
import '../../features/auth/data/auth_repository_impl.dart';
import '../../features/dashboard/data/dashboard_repository.dart';
import '../../features/documents/data/documents_repository.dart';
import '../../features/installments/data/installments_repository.dart';
import '../../features/partners/data/partners_repository.dart';
import '../../features/partners/data/wallet_repository.dart';
import '../../features/projects/data/projects_repository.dart';
import '../../features/staff/data/staff_repository.dart';
import '../../features/activity_log/data/activity_log_repository.dart';
import '../../features/notifications/data/notifications_repository.dart';
import '../../features/notifications/presentation/cubit/notification_badge_cubit.dart';
import '../../features/subscription/data/subscription_repository.dart';
import '../../features/reports/data/reports_repository.dart';

final getIt = GetIt.instance;

/// DI ro'yxati — `get_it` orqali qo'lda registratsiya (E_HISOB_FLUTTER_UI_UX_TZ.md
/// 4-bo'lim: "get_it + injectable yoki Riverpod").
Future<void> setupInjector() async {
  // --- Platform / storage ---
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  getIt.registerSingleton<LocalCacheService>(LocalCacheService(sharedPreferences));
  getIt.registerSingleton<SecureStorageService>(SecureStorageService());
  getIt.registerSingleton<DeviceInfoService>(DeviceInfoService(getIt()));
  getIt.registerSingleton<Connectivity>(Connectivity());

  // --- Global cubits (session-wide, provided at app root) ---
  getIt.registerSingleton<AuthSessionController>(AuthSessionController());
  getIt.registerSingleton<OwnerContextCubit>(OwnerContextCubit(getIt()));
  getIt.registerSingleton<SubscriptionCubit>(SubscriptionCubit());
  getIt.registerSingleton<ConnectivityCubit>(ConnectivityCubit(getIt()));
  getIt.registerSingleton<ThemeCubit>(ThemeCubit(getIt()));
  getIt.registerSingleton<LocaleCubit>(LocaleCubit(getIt()));
  getIt.registerSingleton<AuthCubit>(AuthCubit(getIt()));

  // --- Network ---
  final dio = DioClient.create(interceptors: [
    AuthInterceptor(secureStorage: getIt(), ownerContextCubit: getIt(), localeCubit: getIt()),
    ErrorInterceptor(authSession: getIt(), subscriptionCubit: getIt(), ownerContextCubit: getIt()),
    AppLoggingInterceptor(),
  ]);
  getIt.registerSingleton<ApiClient>(ApiClient(dio));
  getIt.registerSingleton<FileUploadService>(FileUploadService(getIt()));

  // --- Auth (registered before UserCubit, which depends on it) ---
  getIt.registerSingleton<AuthRemoteDataSource>(AuthRemoteDataSource(getIt()));
  getIt.registerSingleton<AuthRepository>(AuthRepositoryImpl(getIt()));
  getIt.registerSingleton<UserCubit>(UserCubit(getIt()));

  // --- Feature repositories ---
  getIt.registerSingleton<DocumentsRepository>(DocumentsRepository(getIt(), getIt()));
  getIt.registerSingleton<DashboardRepository>(DashboardRepository(getIt()));
  getIt.registerSingleton<PartnersRepository>(PartnersRepository(getIt()));
  getIt.registerSingleton<WalletRepository>(WalletRepository(getIt()));
  getIt.registerSingleton<InstallmentsRepository>(InstallmentsRepository(getIt()));
  getIt.registerSingleton<ProjectsRepository>(ProjectsRepository(getIt()));
  getIt.registerSingleton<StaffRepository>(StaffRepository(getIt()));
  getIt.registerSingleton<ActivityLogRepository>(ActivityLogRepository(getIt()));
  getIt.registerSingleton<NotificationsRepository>(NotificationsRepository(getIt()));
  getIt.registerSingleton<NotificationBadgeCubit>(NotificationBadgeCubit(getIt()));
  getIt.registerSingleton<SubscriptionRepository>(SubscriptionRepository(getIt()));
  getIt.registerSingleton<ReportsRepository>(ReportsRepository(getIt()));

  // Ma'lumotnomalarni fon rejimida yangilash (MOBILE_APP_TZ.md 5.2, 4.11).
  unawaited(getIt<DocumentsRepository>().refreshCurrencies());
}
