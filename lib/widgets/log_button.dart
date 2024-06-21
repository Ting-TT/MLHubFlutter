import 'package:flutter/material.dart';

Widget logButton(BuildContext context, Function onTap, bool isSelected) {
  return ListTile(
    leading: const Icon(Icons.list_alt),
    title: const Text('Log'),
    onTap: () => onTap(),
    selected: isSelected,
    selectedTileColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
    selectedColor: Theme.of(context).colorScheme.primary,
  );
}
