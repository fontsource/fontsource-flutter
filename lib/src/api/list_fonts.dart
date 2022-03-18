import 'dart:convert';

import 'package:http/http.dart' as http;

import 'constants.dart';

/// Returns a list of font ids.
Future<List<String>> listFonts() async {
  var response = await http.get(Uri.parse('$apiUrl/fontlist'));
  Map<String, String> fontList =
      jsonDecode(response.body).cast<String, String>();

  return fontList.keys.toList();
}
