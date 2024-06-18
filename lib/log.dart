/// The log page capturing the executed ML commands and the outputs.
///
/// Copyright (C) 2024 Authors
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

final logProvider = StateProvider<List<String>>((ref) => []);

void updateLog(WidgetRef ref, String message) {
  ref.read(logProvider.notifier).update((state) => [...state, message]);
}

class LogPage extends ConsumerStatefulWidget {
  @override
  LogPageState createState() => LogPageState();
}

class LogPageState extends ConsumerState<LogPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final logs = ref.watch(logProvider);

    // Automatically scroll to the bottom of the log list
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          // Schedule a callback for after the build phase, ensuring the ListView has been built
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: logs.isEmpty
            ? const Center(child: Text('No logs available'))
            : ListView.builder(
                controller: _scrollController,
                itemCount: logs.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(
                    logs[index],
                    style: const TextStyle(fontFamily: 'Monospace'),
                  ),
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
