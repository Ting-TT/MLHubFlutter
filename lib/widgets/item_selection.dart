import 'package:flutter/material.dart';

class SelectableItem {
  final String name;
  final bool isEnabled;

  SelectableItem({required this.name, this.isEnabled = true});
}

class SelectionButtons extends StatelessWidget {
  final String selectedItem;
  final ValueChanged<String> onItemSelected;
  final List<SelectableItem> items;

  const SelectionButtons({
    super.key,
    required this.selectedItem,
    required this.onItemSelected,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0, // Space between buttons
      children: items.map((item) {
        return ElevatedButton(
          onPressed: item.isEnabled ? () => onItemSelected(item.name) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: item.isEnabled
                ? (selectedItem == item.name ? Colors.purple[100] : null)
                : Colors.grey,
            foregroundColor: item.isEnabled ? null : Colors.black45,
          ),
          child: Text(item.name),
        );
      }).toList(),
    );
  }
}
