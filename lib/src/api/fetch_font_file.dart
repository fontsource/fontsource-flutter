import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'constants.dart';

/// Font format options
enum FontFormat {
  /// True Type Format
  ttf,

  /// Web Open Font Format
  woff,

  /// Web Open Font Format version 2
  woff2
}

/// Fetch specified variant of a font file.
Future<Uint8List> fetchFontFile(
    String fontId, String subset, int weight, String style, FontFormat format,
    [String? version]) async {
  String ext = '';
  switch (format) {
    case FontFormat.ttf:
      ext = 'ttf';
      break;
    case FontFormat.woff:
      ext = 'woff';
      break;
    case FontFormat.woff2:
      ext = 'woff2';
      break;
    default:
  }
  final response = await http.get(Uri.parse(
      '$apiUrl/v1/fonts/$fontId/$subset-$weight-$style.$ext${version == null ? '' : '?version=$version'}'));

  return response.bodyBytes;
}
