import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final logProvider = StateProvider<List<String>>((ref) => []);

void updateLog(WidgetRef ref, String message, {bool includeTimestamp = false}) {
  String logMessage = message;
  if (includeTimestamp) {
    final now = DateTime.now();
    String timeStamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    logMessage = "---[$timeStamp]\n $message";
  }
  ref.read(logProvider.notifier).update((state) => [...state, logMessage]);
}

class LogPage extends ConsumerStatefulWidget {
  @override
  _LogPageState createState() => _LogPageState();
}

class _LogPageState extends ConsumerState<LogPage> {

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
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    // Check for the separator marker in the log entry
                    bool hasTimestamp = logs[index].startsWith("---");
                    return Column(
                      children: <Widget>[
                        if (hasTimestamp) Divider(color: Colors.grey),  // Insert a Divider if the log has a timestamp
                        ListTile(
                          title: Text(
                            logs[index].replaceAll("---", ""),  // Remove the separator marker when displaying
                            style: TextStyle(fontFamily: 'Monospace')
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ),
    );
  }
}

