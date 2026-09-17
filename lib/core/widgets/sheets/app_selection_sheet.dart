import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'app_bottom_sheet.dart';

class AppSelectionItem<T> {
  const AppSelectionItem({required this.value, required this.label, this.subtitle});
  final T value;
  final String label;
  final String? subtitle;
}

/// Dropdown o'rnini bosuvchi yagona tanlov sheeti — tap bilan darhol yopiladi
/// (E_HISOB_FLUTTER_UI_UX_TZ.md 2-bo'lim, E_HISOB_FLUTTER_UI_COMPONENTS_TZ.md 53-54).
Future<T?> showAppSelectionSheet<T>(
  BuildContext context, {
  required String title,
  required List<AppSelectionItem<T>> items,
  T? selectedValue,
  bool searchable = false,
}) {
  return showAppBottomSheet<T>(
    context,
    title: title,
    heightFactor: 0.7,
    child: _SelectionList<T>(items: items, selectedValue: selectedValue, searchable: searchable),
  );
}

class _SelectionList<T> extends StatefulWidget {
  const _SelectionList({required this.items, this.selectedValue, required this.searchable});
  final List<AppSelectionItem<T>> items;
  final T? selectedValue;
  final bool searchable;

  @override
  State<_SelectionList<T>> createState() => _SelectionListState<T>();
}

class _SelectionListState<T> extends State<_SelectionList<T>> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final filtered = _query.isEmpty
        ? widget.items
        : widget.items
            .where((i) => i.label.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.searchable)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(hintText: 'Qidirish...', prefixIcon: Icon(Icons.search)),
            ),
          ),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final item = filtered[index];
              final selected = item.value == widget.selectedValue;
              return ListTile(
                title: Text(item.label),
                subtitle: item.subtitle != null ? Text(item.subtitle!) : null,
                trailing: selected ? Icon(Icons.check_circle, color: colors.primary) : null,
                onTap: () => Navigator.of(context).pop(item.value),
              );
            },
          ),
        ),
      ],
    );
  }
}
