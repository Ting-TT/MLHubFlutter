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
        logButton(context, () => onDestinationSelected(5), selectedIndex == 5),
        aboutButton(context, appVersion),
        versionLabel(appVersion),
      ],
    );
  }

  List<Widget> _createDrawerItems(BuildContext context) {
    return [
      _drawerItem(context, Icons.home, 'Home', 0),
      _drawerItem(context, Icons.language, 'Language', 1),
      _drawerItem(context, Icons.transcribe, 'Transcribe', 2, indent: 32),
      _drawerItem(context, Icons.translate, 'Translate', 3, indent: 32),
      _drawerItem(context, Icons.visibility, 'Vision', 4),
      // Index 5 is used for logButton
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