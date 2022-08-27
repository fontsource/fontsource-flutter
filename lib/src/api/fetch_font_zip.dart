import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'constants.dart';

/// Fetch zip bundle of a font.
Future<Uint8List> fetchFontZip(String fontId, [String? version]) async {
  final response = await http.get(Uri.parse(
      '$apiUrl/v1/fonts/$fontId/download${version == null ? '' : '?version=$version'}'));

  return response.bodyBytes;
}
