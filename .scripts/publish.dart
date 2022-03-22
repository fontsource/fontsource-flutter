import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

import 'utils.dart';
import 'test.dart' as test;

final changelogExp = RegExp(r'## +(.*?)\s*\n([\s\S]+?)\n\s*##');

Future<void> _dartPublish() async {
  await runProcess('dart', ['pub', 'publish', '-f']);
}

Future<void> _githubRelease(String token, String version, String body) async {
  final response = await http.post(
    Uri.parse(
        'https://api.github.com/repos/fontsource/fontsource-flutter/releases'),
    headers: {
      'accept': 'toapplication/vnd.github.v3+json',
      'Authorization': 'token ${token}'
    },
    body: jsonEncode({'tag_name': 'v$version', 'body': body}),
  );
  print('GitHub Release: ${response.reasonPhrase}');
  final responseError = jsonDecode(response.body)['errors'];
  if (responseError != null) throw Exception(responseError);
}

void main(List<String> args) async {
  await test.main();

  final pubCredentials = args[0];
  final githubToken = args[1];

  String version;
  String body;
  try {
    try {
      final matches =
          changelogExp.firstMatch(File('CHANGELOG.md').readAsStringSync());
      if (matches == null) throw Exception();
      final match1 = matches.group(1);
      if (match1 == null) throw Exception();
      final match2 = matches.group(2);
      if (match2 == null) throw Exception();
      version = match1;
      body = match2;
    } catch (e) {
      throw Exception('Invalid changelog.');
    }

    if (version !=
        loadYaml(File('pubspec.yaml').readAsStringSync())['version']) {
      throw Exception('Pubspec version differs from changelog.');
    }

    File(path.join(
        Platform.environment['HOME']!, '.config/dart/pub-credentials.json'))
      ..createSync(recursive: true)
      ..writeAsStringSync(pubCredentials);

    await _dartPublish();

    print('');

    await _githubRelease(githubToken, version, body);
  } catch (e) {
    stderr.writeln(e);
    exit(1);
  }
}
