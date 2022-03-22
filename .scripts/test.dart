import 'utils.dart';

Future<void> main() async {
  await runProcess('dart', ['pub', 'get'], 'example');
  await runProcess('dart', ['run', 'fontsource'], 'example');
}
