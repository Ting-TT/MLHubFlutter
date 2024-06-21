import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:mlflutter/constants/app_constants.dart';
import 'package:mlflutter/navigation/navigation_drawer.dart';
import 'package:mlflutter/navigation/page_router.dart';

class MLHub extends ConsumerWidget {
  const MLHub({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'MLFlutter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MLHubMainPage(),
    );
  }
}

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
      body: Row(
        children: [
          SizedBox(
            width: sidebarWidth,
            child: AppNavigationDrawer(
              selectedIndex: selectedIndex,
              onDestinationSelected: _onDestinationSelected,
              appVersion: appVersion,
            ),
          ),
          Expanded(
            child: PageRouter.getPage(selectedIndex),
          ),
        ],
      ),
    );
  }
}
