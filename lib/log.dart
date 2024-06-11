import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final logProvider = StateProvider<List<String>>((ref) => []);

void updateLog(WidgetRef ref, String message) {
  ref.read(logProvider.notifier).update((state) => [...state, message]);
}

class LogPage extends ConsumerStatefulWidget {
  @override
  _LogPageState createState() => _LogPageState();
}

class _LogPageState extends ConsumerState<LogPage> {
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
