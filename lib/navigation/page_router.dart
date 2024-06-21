import 'package:flutter/material.dart';

import 'package:mlflutter/features/home_panel.dart';
import 'package:mlflutter/features/language/transcibe/transcibe_panel.dart';
import 'package:mlflutter/features/language/translate/translate_panel.dart';
import 'package:mlflutter/features/log/log_panel.dart';
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
