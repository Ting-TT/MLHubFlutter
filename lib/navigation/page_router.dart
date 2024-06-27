import 'package:flutter/material.dart';

import 'package:mlflutter/features/intro.dart';
import 'package:mlflutter/features/language/transcibe.dart';
import 'package:mlflutter/features/language/translate.dart';
import 'package:mlflutter/features/log.dart';
import 'package:mlflutter/features/vision/vision_panel.dart';

class PageRouter {
  static Widget getPage(int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        return HomePage();
      case 1:
        return TranscribePage();
      case 2:
        return TranslatePage();
      case 3:
        return VisionPage();
      case 4:
        return LogPage();
      default:
        return HomePage();
    }
  }
}
