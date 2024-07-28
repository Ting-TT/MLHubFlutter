/// A widget that creates a log button for the navigation drawer.
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
