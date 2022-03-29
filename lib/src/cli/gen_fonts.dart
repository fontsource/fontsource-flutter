import 'dart:io';

import 'package:json2yaml/json2yaml.dart';
import 'package:progress_bar/progress_bar.dart';

import '../../api.dart';
import '../utils.dart';
import 'config.dart';

final _genPackagePath = cwdJoin('.fontsource');
final _genFontPath = cwdJoin('.dart_tool/fontsource');

void genFonts(FontsourceConfig config) {
  clearDirectory(_genPackagePath);
  clearDirectory(_genFontPath);

  final bar = ProgressBar('Getting fonts: [:bar] :percent :etas ',
      width: 20,
      total: config.fonts.keys
          .map((id) =>
              config.fonts[id]!.subsets.length *
              config.fonts[id]!.weights.length *
              config.fonts[id]!.styles.length)
          .reduce((a, b) => a + b));

  Map<String, dynamic> pubspec = {
    'name': 'fontsource_gen',
    'environment': {'sdk': '>=2.15.1 <3.0.0', 'flutter': '>=1.17.0'},
    'flutter': {
      'fonts': config.fonts.keys.map((id) {
        final fonts = [];
        for (var subset in config.fonts[id]!.subsets) {
          for (var weight in config.fonts[id]!.weights) {
            for (var style in config.fonts[id]!.styles) {
              final font = {
                'asset':
                    '../.dart_tool/fontsource/$id/$subset-$weight-$style.ttf',
                'weight': weight
              };
              if (style == 'italic') font['style'] = 'italic';
              fonts.add(font);

              fetchFontFile(id, subset, weight, style, FontFormat.ttf,
                      config.fonts[id]!.version)
                  .then((value) {
                Directory('$_genFontPath/$id').createSync(recursive: true);
                bar.tick();
                return File('$_genFontPath/$id/$subset-$weight-$style.ttf')
                    .writeAsBytes(value);
              });
            }
          }
        }

        return ({'family': config.fonts[id]!.metadata.family, 'fonts': fonts});
      }).toList()
    }
  };

  File('$_genPackagePath/pubspec.yaml')
      .writeAsStringSync(json2yaml(pubspec, yamlStyle: YamlStyle.pubspecYaml));

  // Install generated fonts as package
  Process.runSync(
      'dart', ['pub', 'add', 'fontsource_gen', '--path', '.fontsource']);
}
