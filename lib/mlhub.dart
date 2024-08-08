/// The main page of the MLHub.
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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:mlflutter/constants/app.dart';
import 'package:mlflutter/navigation/drawer.dart';
import 'package:mlflutter/navigation/page_router.dart';

class MLHubMainPage extends ConsumerStatefulWidget {
  const MLHubMainPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MLHubMainPageState();
}

class _MLHubMainPageState extends ConsumerState<MLHubMainPage> {
  @override
  void initState() {
    super.initState();
    _fetchAppVersion();
  }

  void _fetchAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version;
    });
  }

  void _onDestinationSelected(int index, BuildContext context) {
    setState(() {
      selectedIndex = index;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SizedBox(
        width: sidebarWidth,
        child: Drawer(
          child: AppNavigationDrawer(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) => _onDestinationSelected(index, context),
            appVersion: appVersion,
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text('MLHub'),
        toolbarHeight: toolbarHeight,
      ),
      body: PageRouter.getPage(selectedIndex),
    );
  }
}
