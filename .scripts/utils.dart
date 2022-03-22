import 'dart:io';

Future<void> runProcess(String executable, List<String> arguments,
    [String? workingDirectory]) async {
  final process = await Process.start(
    executable,
    arguments,
    workingDirectory: workingDirectory,
  );
  stdout.addStream(process.stdout);
  stderr.addStream(process.stderr);
  final exitCode = await process.exitCode;
  if (exitCode != 0) exit(exitCode);
}
