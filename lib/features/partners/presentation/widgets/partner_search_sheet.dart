import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_durations.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/media/app_avatar.dart';
import '../../../../core/widgets/sheets/app_bottom_sheet.dart';
import '../../data/partner_models.dart';
import '../../data/partners_repository.dart';

/// `EntitySelectionSheet<Partner>` — qidiruvli hamkor tanlash
/// (E_HISOB_FLUTTER_UI_COMPONENTS_TZ.md 54, 168).
Future<Partner?> showPartnerSearchSheet(BuildContext context) {
  return showAppBottomSheet<Partner>(
    context,
    title: 'Hamkorni tanlang',
    heightFactor: 0.85,
    child: const _PartnerSearchList(),
  );
}

class _PartnerSearchList extends StatefulWidget {
  const _PartnerSearchList();

  @override
  State<_PartnerSearchList> createState() => _PartnerSearchListState();
}

class _PartnerSearchListState extends State<_PartnerSearchList> {
  List<Partner> _items = [];
  bool _loading = true;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _search('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _search(String query) async {
    setState(() => _loading = true);
    final result = await getIt<PartnersRepository>().getPartnersSimple(search: query);
    if (!mounted) return;
    setState(() {
      _items = result.dataOrNull ?? [];
      _loading = false;
    });
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: AppDurations.searchDebounceMs), () => _search(value));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
            autofocus: true,
            onChanged: _onChanged,
            decoration: const InputDecoration(hintText: 'Hamkorni qidiring', prefixIcon: Icon(Icons.search)),
          ),
        ),
        Flexible(
          child: _loading
              ? const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator()))
              : ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final partner = _items[index];
                    return ListTile(
                      leading: AppAvatar(name: partner.name, size: 40),
                      title: Text(partner.name),
                      subtitle: Text(partner.phone, style: TextStyle(color: colors.textSecondary)),
                      onTap: () => Navigator.of(context).pop(partner),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
