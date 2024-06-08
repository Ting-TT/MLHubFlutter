import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final logProvider = StateProvider<List<String>>((ref) => []);

void updateLog(WidgetRef ref, String message, {bool includeTimestamp = false}) {
  String logMessage = message;
  if (includeTimestamp) {
    final now = DateTime.now();
    String timeStamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    logMessage = "[$timeStamp]\n$message";
  }
  ref.read(logProvider.notifier).update((state) => [...state, logMessage]);
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

    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: SelectionArea(
          child: logs.isEmpty
              ? Center(child: Text('No logs available'))
              : ListView.builder(
                  controller: _scrollController,
                  itemCount: logs.length,
                  itemBuilder: (context, index) => ListTile(
                    title: Text(logs[index],
                        style: TextStyle(fontFamily: 'Monospace')),
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
