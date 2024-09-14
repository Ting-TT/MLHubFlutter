import 'package:mlflutter/utils/run_executable_with_arguments.dart';

/// From flutter_file_picker

Future<String> getPathToExecutable(String executable) async {
  final path = await runExecutableWithArguments('which', [executable]);
  if (path == null) {
    throw Exception(
      'Couldn\'t find the executable $executable in the path.',
    );
  }
  return path;
}
