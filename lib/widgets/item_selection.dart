/// This helps to display a list of selectable buttons.
///
/// Copyright (C) 2024 Authors
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program.  If not, see <https://www.gnu.org/licenses/>.
///
/// Authors: Ting Tang

library;

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
