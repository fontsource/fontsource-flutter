import 'dart:io';
import 'package:fontsource/api.dart';
import 'package:yaml/yaml.dart';

import '../utils.dart';

class FontConfig {
  List<String> subsets;
  List<int> weights;
  List<String> styles;
  FontMetadata metadata;
  String? version;
  FontConfig(this.subsets, this.weights, this.styles, this.metadata,
      [this.version]);
  @override
  String toString() {
    return '{subsets: $subsets, weights: $weights, styles: $styles}';
  }
}

class FontsourceConfig {
  Map<String, FontConfig> fonts;
  FontsourceConfig(this.fonts);
  @override
  String toString() {
    return '{fonts: $fonts}';
  }
}

Future<FontsourceConfig> getConfig() async {
  dynamic configYaml;
  try {
    File fontsourceFile = File(cwdJoin('fontsource.yaml'));
    if (fontsourceFile.existsSync()) {
      String fontsourceFileString = fontsourceFile.readAsStringSync();

      if (fontsourceFileString.isNotEmpty) {
        configYaml = loadYaml(fontsourceFileString);
      }
    }
    if (configYaml == null) {
      File pubspecFile = File(cwdJoin('pubspec.yaml'));

      if (pubspecFile.existsSync()) {
        dynamic pubspecYaml = loadYaml(pubspecFile.readAsStringSync());

        if (pubspecYaml['fontsource'] != null) {
          configYaml = pubspecYaml['fontsource'];
        }
      }
    }
    if (configYaml == null) throw Exception();
  } catch (e) {
    throw Exception('Fontsource config not found.');
  }

  Map configMap = configYaml;
  Map fontsMap = configMap['fonts'] ?? {};
  final config = FontsourceConfig({});
  await Future.wait(fontsMap.keys.map((id) async {
    FontMetadata metadata;
    try {
      metadata = (await listFontMetadata(id: id))[0];
    } catch (e) {
      throw Exception('Font $id not found.');
    }

    List<String> subsets;
    List<int> weights;
    List<String> styles;
    if (fontsMap[id]?['subsets'] == null || fontsMap[id]['subsets'] == 'all') {
      subsets = metadata.subsets;
    } else {
      subsets = (fontsMap[id]['subsets'] as YamlList)
          .map((subset) => subset as String)
          .toList();
      for (var subset in subsets) {
        if (!metadata.subsets.contains(subset)) {
          throw Exception(
              'Subset $subset not found in font ${metadata.family}');
        }
      }
    }
    if (fontsMap[id]?['weights'] == null || fontsMap[id]['weights'] == 'all') {
      weights = metadata.weights;
    } else {
      weights = (fontsMap[id]['weights'] as YamlList)
          .map((weight) => weight as int)
          .toList();
      for (var weight in weights) {
        if (!metadata.weights.contains(weight)) {
          throw Exception(
              'Weight $weight not found in font ${metadata.family}');
        }
      }
    }
    if (fontsMap[id]?['weights'] == null || fontsMap[id]['styles'] == 'all') {
      styles = metadata.styles;
    } else {
      styles = (fontsMap[id]['styles'] as YamlList)
          .map((style) => style as String)
          .toList();
      for (var style in styles) {
        if (!metadata.styles.contains(style)) {
          throw Exception('Style $style not found in font ${metadata.family}');
        }
      }
    }
    String? version = fontsMap[id]?['version'];
    if (version == 'latest') version = null;
    config.fonts[id] = FontConfig(
        subsets, weights, styles, metadata, fontsMap[id]?['version']);
  }));

  return config;
}
