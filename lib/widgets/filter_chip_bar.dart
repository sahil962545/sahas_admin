import 'package:flutter/material.dart';

class FilterChipBar extends StatelessWidget {
  final List<String> options;
  final String selectedOption;
  final ValueChanged<String> onSelected;

  const FilterChipBar({
    super.key,
    required this.options,
    required this.selectedOption,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: options.map((option) {
          final isSelected = selectedOption == option;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              selected: isSelected,
              label: Text(option),
              onSelected: (_) => onSelected(option),
              showCheckmark: false,
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
              labelStyle: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
