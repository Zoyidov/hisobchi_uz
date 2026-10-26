import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hisobchi_uz/core/cubits/user_cubit.dart';
import 'package:hisobchi_uz/core/cubits/owner_context_cubit.dart';
import 'package:hisobchi_uz/core/network/api_result.dart';
import 'package:hisobchi_uz/core/router/route_paths.dart';
import 'package:hisobchi_uz/features/auth/presentation/auth_navigation.dart';
import 'package:hisobchi_uz/core/domain/entities/user_entity.dart';
import 'package:hisobchi_uz/core/network/api_client.dart';
import 'package:hisobchi_uz/core/storage/secure_storage_service.dart';
import 'package:hisobchi_uz/core/utils/formatters/phone_formatter.dart';
import 'package:hisobchi_uz/features/auth/data/auth_remote_data_source.dart';
import 'package:hisobchi_uz/features/auth/data/auth_repository_impl.dart';
import 'package:hisobchi_uz/features/auth/presentation/cubit/otp_cubit.dart';
import 'package:hisobchi_uz/features/auth/presentation/cubit/reset_password_cubit.dart';

class _Storage extends SecureStorageService {
  @override
  Future<String?> readToken() async => 'session-token';
  String? ownerId;
  @override
  Future<String?> readOwnerContext() async => ownerId;
  @override
  Future<void> saveOwnerContext(String ownerId) async => this.ownerId = ownerId;
  @override
  Future<void> clearOwnerContext() async => ownerId = null;
}

class _UserRepository extends AuthRepositoryImpl {
  _UserRepository(this.user) : super(AuthRemoteDataSource(ApiClient(Dio())));
  final UserEntity user;
  @override
  Future<ApiResult<UserEntity>> me() async => ApiResult.success(user);
}

UserEntity _user(List<String> roles, List<int> owners) => UserEntity.fromJson({
  'user_id': 1,
  'role': roles,
  'works_for': owners.map((id) => {'owner_id': id}).toList(),
});

void main() {
  late List<RequestOptions> requests;
  late Dio dio;
  late AuthRepositoryImpl repository;

  setUp(() {
    requests = [];
    dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests.add(options);
          handler.resolve(
            Response(
              requestOptions: options,
              data: {
                'status': true,
                'result': {'token': 'new-token', 'verify_token': 'verified'},
              },
            ),
          );
        },
      ),
    );
    repository = AuthRepositoryImpl(
      AuthRemoteDataSource(ApiClient(dio), secureStorage: _Storage()),
    );
  });

  tearDown(() => dio.close(force: true));

  test('only a sole owner without workplaces skips account selection', () {
    expect(_user(['user'], []).requiresAccountSelection, isFalse);
    expect(_user(['staff'], [2]).requiresAccountSelection, isTrue);
    expect(_user(['staff'], [2, 3]).requiresAccountSelection, isTrue);
    expect(_user(['user'], [2]).requiresAccountSelection, isTrue);
    expect(_user(['user', 'staff'], [2]).requiresAccountSelection, isTrue);
    expect(_user(['staff'], []).requiresAccountSelection, isTrue);
  });

  for (final roles in [
    <String>['user'],
    <String>['staff'],
    <String>['user', 'staff'],
  ]) {
    testWidgets('navigation selects the correct context for $roles', (
      tester,
    ) async {
      final user = _user(roles, roles.contains('staff') ? [2, 3] : []);
      final storage = _Storage();
      final owner = OwnerContextCubit(storage);
      await owner.switchTo(const OwnerContext(ownerId: 99));
      final users = UserCubit(_UserRepository(user));
      await users.loadMe();
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => TextButton(
              onPressed: () => AuthNavigation.goToNextAfterPincode(context),
              child: const Text('continue'),
            ),
          ),
          GoRoute(
            path: RoutePaths.accountSelection,
            builder: (_, _) => const Text('select-account'),
          ),
          GoRoute(
            path: RoutePaths.dashboard,
            builder: (_, _) => const Text('dashboard'),
          ),
        ],
      );
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider.value(value: users),
            BlocProvider.value(value: owner),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.tap(find.text('continue'));
      await tester.pumpAndSettle();
      if (roles.contains('staff')) {
        expect(find.text('select-account'), findsOneWidget);
      } else {
        expect(find.text('dashboard'), findsOneWidget);
        expect(owner.state.isStaffMode, isFalse);
        expect(storage.ownerId, isNull);
      }
      await tester.pumpWidget(const SizedBox());
      router.dispose();
      await users.close();
      await owner.close();
    });
  }

  for (final scenario in [
    (
      name: 'owner and staff resumes own account',
      roles: ['user', 'staff'],
      owners: [2, 3],
      saved: null,
      expected: null,
    ),
    (
      name: 'owner and staff resumes selected workplace',
      roles: ['user', 'staff'],
      owners: [2, 3],
      saved: 3,
      expected: 3,
    ),
    (
      name: 'staff resumes second workplace',
      roles: ['staff'],
      owners: [2, 3],
      saved: 3,
      expected: 3,
    ),
    (
      name: 'removed workplace falls back to own account',
      roles: ['user', 'staff'],
      owners: [2],
      saved: 99,
      expected: null,
    ),
    (
      name: 'staff without saved workplace resumes an available workplace',
      roles: ['staff'],
      owners: [2, 3],
      saved: null,
      expected: 2,
    ),
    (
      name:
          'staff removed from selected workplace resumes an available workplace',
      roles: ['staff'],
      owners: [2, 3],
      saved: 99,
      expected: 2,
    ),
    (
      name: 'owner with no workplaces skips selection on reopening',
      roles: ['user', 'staff'],
      owners: <int>[],
      saved: null,
      expected: null,
    ),
  ]) {
    testWidgets(scenario.name, (tester) async {
      final storage = _Storage()..ownerId = scenario.saved?.toString();
      final owner = OwnerContextCubit(storage);
      final users = UserCubit(
        _UserRepository(_user(scenario.roles, scenario.owners)),
      );
      await users.loadMe();
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => TextButton(
              onPressed: () => AuthNavigation.resumeSession(context),
              child: const Text('reopen'),
            ),
          ),
          GoRoute(
            path: RoutePaths.accountSelection,
            builder: (_, _) => const Text('select-account'),
          ),
          GoRoute(
            path: RoutePaths.dashboard,
            builder: (_, _) => const Text('dashboard'),
          ),
        ],
      );
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider.value(value: users),
            BlocProvider.value(value: owner),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.tap(find.text('reopen'));
      await tester.pumpAndSettle();
      expect(find.text('dashboard'), findsOneWidget);
      expect(find.text('select-account'), findsNothing);
      expect(owner.state.ownerId, scenario.expected);
      expect(storage.ownerId, scenario.expected?.toString());
      await tester.pumpWidget(const SizedBox());
      router.dispose();
      await users.close();
      await owner.close();
    });
  }

  test('normalization keeps a local phone starting with 998 intact', () {
    expect(PhoneFormatter.toApi('998123456'), '998123456');
    expect(PhoneFormatter.toApi('+998 (99) 812-34-56'), '998123456');
  });

  test('reset requests use raw OTP and return the new session token', () async {
    await repository.sendOtp('+998 (90) 123-45-67');
    final result = await repository.resetPassword(
      phone: '+998 (90) 123-45-67',
      otpCode: '0123',
      password: 'new-password',
    );
    expect(requests[0].path, '/auth/otp');
    expect(requests[0].data, {'phone': '901234567'});
    expect(requests[1].path, '/auth/reset-password');
    expect(requests[1].data, {
      'phone': '901234567',
      'otp_code': '0123',
      'password': 'new-password',
    });
    expect(result.isSuccess, isTrue);
    result.when(
      success: (value) => expect(value.token, 'new-token'),
      failure: (_) => fail('reset failed'),
    );
  });

  test(
    'owner activation sends the session token like the source project',
    () async {
      expect((await repository.activateOwnAccount()).isSuccess, isTrue);
      expect(requests.single.path, '/auth/activate-own-account');
      expect(requests.single.data, {'token': 'session-token'});
    },
  );

  testWidgets(
    'reset OTP is checked by reset-password, not registration verification',
    (tester) async {
      final cubit = OtpCubit(
        repository,
        phone: '901234567',
        mode: OtpMode.resetPassword,
      );
      await cubit.submit('123');
      expect(cubit.state, isA<OtpCountingDown>());
      await cubit.submit('0123');
      expect(cubit.state, isA<OtpVerified>());
      expect((cubit.state as OtpVerified).payload, '0123');
      expect(requests, isEmpty);
      await tester.pump(const Duration(seconds: 61));
      expect(cubit.state.secondsRemaining, 0);
      await tester.runAsync(() => cubit.resend());
      expect(requests.single.path, '/auth/otp');
      await cubit.close();
    },
  );

  test('slow OTP verification is not overwritten by the countdown', () async {
    final pending = Completer<void>();
    dio.interceptors.insert(
      0,
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          await pending.future;
          handler.next(options);
        },
      ),
    );
    final cubit = OtpCubit(
      repository,
      phone: '901234567',
      mode: OtpMode.register,
    );
    final submission = cubit.submit('0123');
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    expect(cubit.state, isA<OtpVerifying>());
    await cubit.submit('0123');
    pending.complete();
    await submission;
    expect(requests.length, 1);
    expect(cubit.state, isA<OtpVerified>());
    await cubit.close();
  });

  test('reset rejects parallel submissions', () async {
    final pending = Completer<void>();
    dio.interceptors.insert(
      0,
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          await pending.future;
          handler.next(options);
        },
      ),
    );
    final cubit = ResetPasswordCubit(repository);
    final submission = cubit.submit(
      phone: '901234567',
      otpCode: '0123',
      password: 'new-password',
    );
    await cubit.submit(
      phone: '901234567',
      otpCode: '0123',
      password: 'new-password',
    );
    pending.complete();
    await submission;
    expect(requests.length, 1);
    expect(cubit.state, isA<ResetPasswordSuccess>());
    await cubit.close();
  });
}
