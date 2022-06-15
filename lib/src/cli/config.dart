import 'dart:convert';
import 'dart:io';

import 'package:fontsource/api.dart';
import 'package:path/path.dart' as path;
import 'package:version/version.dart';
import 'package:yaml/yaml.dart';

class FontConfig {
  Set<String> subsets;
  Set<int> weights;
  Set<String> styles;
  FontMetadata metadata;
  String? version;
  FontConfig(this.subsets, this.weights, this.styles, this.metadata,
      [this.version]);
  @override
  String toString() {
    return '{subsets: $subsets, weights: $weights, styles: $styles, version: $version}';
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

late FontsourceConfig _config;
late Set<String> _scannedPackages;
Map<String, String>? _packageSources;

Future<void> _resolve(String dir, [bool isRoot = false]) async {
  Map configMap;
  Set<String> dependencies = {};

  try {
    late YamlMap configYaml;
    bool configFound = false;

    File pubspecFile = File(path.join(dir, 'pubspec.yaml'));
    if (pubspecFile.existsSync()) {
      YamlMap pubspecYaml = loadYaml(pubspecFile.readAsStringSync());

      if (pubspecYaml.containsKey('fontsource')) {
        configYaml = pubspecYaml['fontsource'] ?? YamlMap();
        configFound = true;
      }

      if (pubspecYaml['dependencies'] != null) {
        dependencies = (pubspecYaml['dependencies'] as YamlMap)
            .keys
            .toSet()
            .cast<String>();
      }
    }

    if (!configFound) {
      File fontsourceFile = File(path.join(dir, 'fontsource.yaml'));
      if (fontsourceFile.existsSync()) {
        String fontsourceFileString = fontsourceFile.readAsStringSync();

        configYaml = loadYaml(fontsourceFileString) ?? {};
        configFound = true;
      }
    }

    if (!configFound) throw Exception();

    configMap = configYaml;
  } catch (e) {
    if (isRoot) {
      throw Exception('Fontsource config not found.');
    } else {
      return;
    }
  }

  for (var key in configMap.keys) {
    if (key != 'include' && key != 'fonts') {
      throw Exception('Unknown key in configuration: $key');
    }
  }
  Set<String> include =
      (configMap['include'] == null || configMap['include'] == 'all'
          ? dependencies
          : (configMap['include'] as YamlList).toSet().cast<String>());

  if (include.isNotEmpty) {
    if (_packageSources == null) {
      final packageConfig =
          jsonDecode(File('.dart_tool/package_config.json').readAsStringSync());

      if (packageConfig['configVersion'] != 2) {
        throw Exception(
            'Unknown package_config.json version: ${packageConfig['configVersion']}');
      }

      _packageSources = {};

      for (var package in (packageConfig['packages'] as List)) {
        var packagePath = path.fromUri(package['rootUri']);
        _packageSources![package['name']] = path.isRelative(packagePath)
            ? (path.normalize(path.join('.dart_tool', packagePath)))
            : (package['rootUri']);
      }
    }

    for (var package in include) {
      if (!_scannedPackages.contains(package)) {
        await _resolve(_packageSources![package] as String);
      }
    }
  }

  Map fontsMap = configMap['fonts'] ?? {};
  await Future.wait(fontsMap.keys.map((id) async {
    FontMetadata metadata;
    try {
      metadata = (_config.fonts[id]?.metadata == null)
          ? (await listFontMetadata(id: id)).first
          : _config.fonts[id]!.metadata;
    } catch (e) {
      throw Exception('Font $id not found.');
    }

    Set<String> subsets;
    Set<int> weights;
    Set<String> styles;

    if (fontsMap[id]?['subsets'] == null || fontsMap[id]['subsets'] == 'all') {
      subsets = metadata.subsets.toSet();
    } else {
      subsets = (fontsMap[id]['subsets'] as YamlList)
          .map((subset) => subset as String)
          .toSet();
      for (var subset in subsets) {
        if (!metadata.subsets.contains(subset)) {
          throw Exception(
              'Subset $subset not found in font ${metadata.family}');
        }
      }
    }

    if (fontsMap[id]?['weights'] == null || fontsMap[id]['weights'] == 'all') {
      weights = metadata.weights.toSet();
    } else {
      weights = (fontsMap[id]['weights'] as YamlList)
          .map((weight) => weight as int)
          .toSet();
      for (var weight in weights) {
        if (!metadata.weights.contains(weight)) {
          throw Exception(
              'Weight $weight not found in font ${metadata.family}');
        }
      }
    }

    if (fontsMap[id]?['styles'] == null || fontsMap[id]['styles'] == 'all') {
      styles = metadata.styles.toSet();
    } else {
      styles = (fontsMap[id]['styles'] as YamlList)
          .map((style) => style as String)
          .toSet();
      for (var style in styles) {
        if (!metadata.styles.contains(style)) {
          throw Exception('Style $style not found in font ${metadata.family}');
        }
      }
    }

    String? version = fontsMap[id]?['version'];
    if (version == 'latest') version = null;

    if (_config.fonts[id] == null) {
      _config.fonts[id] = FontConfig(
          subsets, weights, styles, metadata, fontsMap[id]?['version']);
    } else {
      _config.fonts[id]?.subsets.addAll(subsets);
      _config.fonts[id]?.weights.addAll(weights);
      _config.fonts[id]?.styles.addAll(styles);

      // Give latest specified version from all packages unless root specifies.
      if (isRoot) {
        _config.fonts[id]?.version = fontsMap[id]?['version'];
      } else {
        if (_config.fonts[id]?.version != null) {
          if (fontsMap[id]?['version'] == null) {
            _config.fonts[id]?.version = null;
          } else {
            if (Version.parse(fontsMap[id]?['version']) >
                Version.parse(_config.fonts[id]!.version!)) {
              _config.fonts[id]?.version = fontsMap[id]?['version'];
            }
          }
        }
      }
    }
  }));
}

Future<FontsourceConfig> getConfig() async {
  _config = FontsourceConfig({});

  _scannedPackages = {};

  await _resolve(Directory.current.path, true);

  return _config;
}
