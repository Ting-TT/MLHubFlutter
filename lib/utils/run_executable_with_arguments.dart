import 'dart:io';

/// From flutter_file_picker

Future<String?> runExecutableWithArguments(
  String executable,
  List<String> arguments,
) async {
  final processResult = await Process.run(executable, arguments);
  final path = processResult.stdout?.toString().trim();
  if (processResult.exitCode != 0 || path == null || path.isEmpty) {
    return null;
  }
  return path;
}
