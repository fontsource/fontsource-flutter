import 'dart:io';

import 'package:json2yaml/json2yaml.dart';
import 'package:progress_bar/progress_bar.dart';

import '../../api.dart';
import 'config.dart';

const _genPath = '.dart_tool/fontsource';

void genFonts(FontsourceConfig config) {
  Directory baseDir = Directory(_genPath);
  if (baseDir.existsSync()) baseDir.deleteSync(recursive: true);
  baseDir.createSync(recursive: true);

  var bar = ProgressBar('Getting fonts: [:bar] :percent :etas ',
      width: 20,
      total: config.keys
          .map((id) =>
              config[id]!.subsets.length *
              config[id]!.weights.length *
              config[id]!.styles.length)
          .reduce((a, b) => a + b));

  Map<String, dynamic> pubspec = {
    'name': 'fontsource_gen',
    'environment': {'sdk': '>=2.15.1 <3.0.0', 'flutter': '>=1.17.0'},
    'flutter': {
      'fonts': config.keys.map((id) {
        var fonts = [];
        for (var subset in config[id]!.subsets) {
          for (var weight in config[id]!.weights) {
            for (var style in config[id]!.styles) {
              var font = {
                'asset': 'fonts/$id/$subset-$weight-$style.ttf',
                'weight': weight
              };
              if (style == 'italic') font['style'] = 'italic';
              fonts.add(font);

              fetchFontFile(id, subset, weight, style, FontFormat.ttf,
                      config[id]!.version)
                  .then((value) {
                Directory('$_genPath/fonts/$id').createSync(recursive: true);
                bar.tick();
                return File('$_genPath/fonts/$id/$subset-$weight-$style.ttf')
                    .writeAsBytes(value);
              });
            }
          }
        }

        return ({'family': config[id]!.metadata.family, 'fonts': fonts});
      }).toList()
    }
  };

  File('$_genPath/pubspec.yaml')
      .writeAsStringSync(json2yaml(pubspec, yamlStyle: YamlStyle.pubspecYaml));

  // Install generated fonts as package
  Process.runSync('dart', ['pub', 'add', 'fontsource_gen', '--path', _genPath]);
}
