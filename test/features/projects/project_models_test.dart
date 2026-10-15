import 'package:flutter_test/flutter_test.dart';
import 'package:hisobchi_uz/features/projects/data/project_models.dart';

void main() {
  test('reads project images while preserving signed URLs', () {
    const url = 'https://example.com/photo.webp?X-Amz-Signature=test';
    final project = Project.fromJson({
      'id': 135,
      'status': 'Jarayonda',
      'files': [
        {'id': 735, 'url': url},
      ],
    });
    expect(project.files.single.id, 735);
    expect(project.files.single.url, url);
    expect(Project.fromJson({'id': 4}).files, isEmpty);
  });

  test(
    'accepts API keys and localized status labels without changing request values',
    () {
      for (final value in ['frozen', 'Muzlatilgan', ' muzlatilgan ']) {
        expect(
          Project.fromJson({'id': 4, 'status': value}).status,
          ProjectStatus.frozen,
        );
      }
      for (final value in ['completed', 'Tugallangan', 'Yakunlangan']) {
        expect(ProjectStatusX.fromApi(value), ProjectStatus.completed);
      }
      expect(ProjectStatusX.fromApi('Jarayonda'), ProjectStatus.inProgress);
      expect(ProjectStatus.frozen.apiValue, 'frozen');
    },
  );
  test('reads nested project balances from the provided API response', () {
    final project = Project.fromJson({
      'id': 4,
      'status': 'Muzlatilgan',
      'accounts': {
        'debt': {'UZS': 3577000, 'USD': 50},
        'credit': {'UZS': 1200000, 'USD': 10},
        'balance': {'UZS': 2377000, 'USD': 40},
      },
    });
    expect(project.status, ProjectStatus.frozen);
    expect(project.accounts!.uzs.income.toString(), '3577000');
    expect(project.accounts!.uzs.cost.toString(), '1200000');
    expect(project.accounts!.uzs.balance.toString(), '2377000');
    expect(project.accounts!.usd.balance.toString(), '40');
  });
  test(
    'retains flat balance response compatibility and nested zero values',
    () {
      final accounts = ProjectAccounts.fromJson({
        'income_uzs': 50,
        'costs_uzs': 20,
        'balance_uzs': 30,
      });
      expect(accounts.uzs.balance.toString(), '30');
      final zero = ProjectAccounts.fromJson({
        'balance': {'UZS': 0},
        'balance_uzs': 30,
      });
      expect(zero.uzs.balance.toString(), '0');
    },
  );
}
