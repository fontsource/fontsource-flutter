import 'dart:convert';

import 'package:http/http.dart' as http;

import 'constants.dart';

/// Class representing a font's metadata.
class FontMetadata {
  String id;
  String family;
  List<String> subsets;
  List<int> weights;
  List<String> styles;
  String defSubset;
  bool variable;
  String lastModified;
  String category;
  String version;
  String type;

  FontMetadata(
      this.id,
      this.family,
      this.subsets,
      this.weights,
      this.styles,
      this.defSubset,
      this.variable,
      this.lastModified,
      this.category,
      this.version,
      this.type);

  /// Create [FontMetadata] from a map.
  FontMetadata.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        family = map['family'],
        subsets = map['subsets'].cast<String>(),
        weights = map['weights'].cast<int>(),
        styles = map['styles'].cast<String>(),
        defSubset = map['defSubset'],
        variable = map['variable'],
        lastModified = map['lastModified'],
        category = map['category'],
        version = map['version'],
        type = map['type'];

  @override
  String toString() {
    return {
      'id': id,
      'family': family,
      'subsets': subsets,
      'weights': weights,
      'styles': styles,
      'defSubset': defSubset,
      'variable': variable,
      'lastModified': lastModified,
      'category': category,
      'version': version,
      'type': type,
    }.toString();
  }
}

/// Returns a list of [FontMetadata]s.
Future<List<FontMetadata>> listFontMetadata(
    {String? id,
    String? family,
    List<String>? subsets,
    List<int>? weights,
    List<String>? styles,
    String? defSubset,
    bool? variable,
    String? lastModified,
    String? category,
    String? version,
    String? type}) async {
  var query = {
    'id': id,
    'family': family,
    'subsets': subsets,
    'weights': weights?.map((weight) => weight.toString()),
    'styles': styles,
    'defSubset': defSubset,
    'variable': variable,
    'lastModified': lastModified,
    'category': category,
    'version': version,
    'type': type,
  };
  query.removeWhere((_, value) => value == null);
  var response = await http
      .get(Uri.parse('$apiUrl/v1/fonts?${Uri(queryParameters: query).query}'));
  List<dynamic> fonts = jsonDecode(response.body);

  return fonts.map((font) => FontMetadata.fromMap(font)).toList();
}
