import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../buttons/app_button.dart';
import 'app_bottom_sheet.dart';
import 'app_selection_sheet.dart';

/// Ko'p tanlovli sheet — checkbox ro'yxat + "N ta tanlandi" sticky panel
/// (E_HISOB_FLUTTER_UI_COMPONENTS_TZ.md 55, MOBILE_APP_TZ.md 10.4-D).
Future<List<T>?> showAppMultiSelectionSheet<T>(
  BuildContext context, {
  required String title,
  required List<AppSelectionItem<T>> items,
  List<T> initiallySelected = const [],
}) {
  return showAppBottomSheet<List<T>>(
    context,
    title: title,
    heightFactor: 0.75,
    child: _MultiSelectionList<T>(items: items, initiallySelected: initiallySelected),
  );
}

class _MultiSelectionList<T> extends StatefulWidget {
  const _MultiSelectionList({required this.items, required this.initiallySelected});
  final List<AppSelectionItem<T>> items;
  final List<T> initiallySelected;

  @override
  State<_MultiSelectionList<T>> createState() => _MultiSelectionListState<T>();
}

class _MultiSelectionListState<T> extends State<_MultiSelectionList<T>> {
  late final Set<T> _selected = Set.of(widget.initiallySelected);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: widget.items.length,
            itemBuilder: (context, index) {
              final item = widget.items[index];
              final checked = _selected.contains(item.value);
              return CheckboxListTile(
                value: checked,
                title: Text(item.label),
                subtitle: item.subtitle != null ? Text(item.subtitle!) : null,
                onChanged: (v) => setState(() {
                  if (v ?? false) {
                    _selected.add(item.value);
                  } else {
                    _selected.remove(item.value);
                  }
                }),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
          child: Row(
            children: [
              Text('${_selected.length} ta tanlandi'),
              const Spacer(),
              AppButton.text(label: 'Bekor qilish', onPressed: () => Navigator.of(context).pop()),
              const SizedBox(width: AppSpacing.xs),
              AppButton.primary(
                label: 'Tanlash',
                expand: false,
                onPressed: () => Navigator.of(context).pop(_selected.toList()),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
