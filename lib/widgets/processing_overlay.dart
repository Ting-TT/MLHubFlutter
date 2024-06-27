import 'package:flutter/material.dart';

class ProcessingOverlay extends StatelessWidget {
  final VoidCallback onCancel;

  const ProcessingOverlay({
    super.key,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.white60, // Semi-transparent overlay
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            const Text(
              'Processing...',
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onCancel,
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
