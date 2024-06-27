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
      case 2:
        return TranscribePage();
      case 3:
        return TranslatePage();
      case 4:
        return VisionPage();
      case 5:
        return LogPage();
      default:
        return HomePage();
    }
  }
}
