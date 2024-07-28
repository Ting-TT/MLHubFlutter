/// Navigation drawer for the MLFlutter app, providing access to different sections.
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

import 'package:mlflutter/widgets/log_button.dart';
import 'package:mlflutter/widgets/about_button.dart';
import 'package:mlflutter/widgets/version_label.dart';

class AppNavigationDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;
  final String appVersion;

  const AppNavigationDrawer({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.appVersion,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: _createDrawerItems(context),
          ),
        ),
        logButton(context, () => onDestinationSelected(4), selectedIndex == 4),
        aboutButton(context, appVersion),
        versionLabel(appVersion),
      ],
    );
  }

  List<Widget> _createDrawerItems(BuildContext context) {
    return [
      _drawerItem(context, Icons.home, 'Home', 0),
      ExpansionTile(
        leading: const Icon(Icons.language),
        title: const Text('Language'),
        children: [
          _drawerItem(context, Icons.transcribe, 'Transcribe', 1, indent: 30.0),
          _drawerItem(context, Icons.translate, 'Translate', 2, indent: 30.0),
        ],
      ),
      _drawerItem(context, Icons.visibility, 'Vision', 3),
      // Index 4 is used for logButton
      // Add more items as needed
    ];
  }

  Widget _drawerItem(
    BuildContext context,
    IconData icon,
    String text,
    int index, {
    double? indent,
  }) {
    return ListTile(
      contentPadding: indent != null ? EdgeInsets.only(left: indent) : null,
      leading: Icon(icon),
      title: Text(text),
      onTap: () => onDestinationSelected(index),
      selected: selectedIndex == index,
      selectedTileColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      selectedColor: Theme.of(context).colorScheme.primary,
    );
  }
}
