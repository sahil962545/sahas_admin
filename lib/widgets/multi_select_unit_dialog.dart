import 'package:flutter/material.dart';
import '../models/unit_model.dart';

class MultiSelectUnitDialog extends StatefulWidget {
  final List<UnitModel> units;
  final List<String> initialSelectedIds;

  const MultiSelectUnitDialog({
    super.key,
    required this.units,
    required this.initialSelectedIds,
  });

  @override
  State<MultiSelectUnitDialog> createState() => _MultiSelectUnitDialogState();
}

class _MultiSelectUnitDialogState extends State<MultiSelectUnitDialog> {
  late List<String> _tempSelectedIds;

  @override
  void initState() {
    super.initState();
    _tempSelectedIds = List<String>.from(widget.initialSelectedIds);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Filter Units',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${_tempSelectedIds.length} Selected',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Quick Select / Clear Controls
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _tempSelectedIds = widget.units.map((u) => u.id).toList();
                      });
                    },
                    icon: const Icon(Icons.select_all_rounded, size: 16),
                    label: const Text('Select All'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _tempSelectedIds.clear();
                      });
                    },
                    icon: const Icon(Icons.clear_all_rounded, size: 16),
                    label: const Text('Clear All'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),

            // Checkbox List of Units
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: widget.units.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final unit = widget.units[index];
                  final isChecked = _tempSelectedIds.contains(unit.id);

                  return CheckboxListTile(
                    title: Text(
                      'Unit ${unit.name}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    value: isChecked,
                    activeColor: theme.colorScheme.primary,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (bool? checked) {
                      setState(() {
                        if (checked == true) {
                          if (!_tempSelectedIds.contains(unit.id)) {
                            _tempSelectedIds.add(unit.id);
                          }
                        } else {
                          _tempSelectedIds.remove(unit.id);
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_tempSelectedIds),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
          child: Text(
            _tempSelectedIds.isEmpty
                ? 'Apply (All Units)'
                : 'Apply (${_tempSelectedIds.length})',
          ),
        ),
      ],
    );
  }
}
