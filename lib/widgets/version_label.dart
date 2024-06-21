import 'package:flutter/material.dart';

Widget versionLabel(String version) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text(
      'Version: $version',
      style: const TextStyle(color: Colors.grey),
    ),
  );
}
