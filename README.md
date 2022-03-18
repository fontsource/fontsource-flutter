# Fontsource for Flutter

Add Fontsource fonts to your flutter app. Direct access to Fontsource API.

## Getting started

To start, create a config in either your `pubspec.yaml` file under the `fontsource` key or in the `fontsource.yaml` file.

The `fontsource` config is a map of font ids to font configs. Each font config can have a `version`, `subsets`, `weights`, and `styles` key. The default is `latest` for the `version`, and `all` for the rest of the keys. This config will tell `fontsource` what to download and bundle into your flutter app. To ensure everything is downloaded, execute `dart run fontsource` after your config is modified. Also make sure to run it whenever your repository is cloned.

`fontsource.yaml`:

```yaml
alex-brush:
  subsets: [latin, latin-ext]
  weights: [400]
  styles: [normal]
```

You can then import the `fontsource` package:

```dart
import 'package:fontsource/fontsource.dart';
```

Use `FontsourceTextStyle` to use a Fontsource font:

```dart
const Text(
  'Hello world!',
  style: FontsourceTextStyle(fontFamily: 'Alex Brush', fontSize: 30),
),
```

`FontsourceTextStyle` extends the `TextStyle` class, so any styling properties can be used to change the way the text looks.

Alternatively, you can use the normal `TextStyle` class by specifying the `package` as `fontsource_gen`. This package is automatically added to your dependencies and generated locally when `dart run fontsource` is executed.
