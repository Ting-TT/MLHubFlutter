import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:mlflutter/constants/app_constants.dart';
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

  void _onDestinationSelected(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SizedBox(
        width: sidebarWidth,
        child: Drawer(
          child: AppNavigationDrawer(
            selectedIndex: selectedIndex,
            onDestinationSelected: _onDestinationSelected,
            appVersion: appVersion,
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text('MLHub'),
      ),
      body: PageRouter.getPage(selectedIndex),
    );
  }
}
