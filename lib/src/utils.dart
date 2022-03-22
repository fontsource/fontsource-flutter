import 'dart:io';

import 'package:path/path.dart';

String cwdJoin(String path) {
  return join(Directory.current.path, path);
}

void clearDirectory(String path) {
  Directory dir = Directory(path);
  if (dir.existsSync()) dir.deleteSync(recursive: true);
  dir.createSync(recursive: true);
}
