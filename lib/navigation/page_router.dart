/// Routes pages based on the selected index for displaying the body part of the MLFlutter app.
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

import 'package:mlflutter/features/intro.dart';
import 'package:mlflutter/features/language/transcibe.dart';
import 'package:mlflutter/features/language/translate.dart';
import 'package:mlflutter/features/log.dart';
import 'package:mlflutter/features/vision/vision.dart';

class PageRouter {
  static Widget getPage(int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        return Intro();
      case 1:
        return Transcribe();
      case 2:
        return Translate();
      case 3:
        return Vision();
      case 4:
        return Log();
      default:
        return Intro();
    }
  }
}
