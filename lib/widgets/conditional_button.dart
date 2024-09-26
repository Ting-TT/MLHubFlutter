/// An ElevatedButton will be disabled or enabled based on conditions.
///
/// Copyright (C) 2024 The Authors
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

class ConditionalButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isEnabled;

  const ConditionalButton({
    required this.onPressed,
    required this.text,
    required this.isEnabled,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: isEnabled ? null : Colors.grey,
        foregroundColor: isEnabled ? null : Colors.black45,
      ),
      child: Text(text),
    );
  }
}
