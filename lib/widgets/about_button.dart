import 'package:flutter/material.dart';

Widget aboutButton(BuildContext context, String appVersion) {
  return ListTile(
    leading: const Icon(Icons.info),
    title: const Text('About'),
    onTap: () => showAboutDialog(
      context: context,
      applicationVersion: 'Current version: $appVersion',
      applicationLegalese: '© 2024 Authors',
      children: const <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 15),
          child: SelectableText(
            'MLHub app provides you with easy access to the latest state of the art in AI, Machine Learning, and Data Science.\nVisit the MLHub Book at https://survivor.togaware.com/mlhub/',
          ),
        ),
      ],
    ),
    selectedTileColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
  );
}
