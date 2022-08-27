# Fontsource for Flutter

Easily add Fontsource fonts to your flutter app. Includes a dart interface for the Fontsource API.

## Getting started

To start, create a config in either your `pubspec.yaml` file under the `fontsource` key or in the `fontsource.yaml` file.

```yaml
include: [my-package] # Defaults to all
fonts:
  alex-brush: # This can be any font id
    version: 4.5.3 # Defaults to latest
    subsets: [latin, latin-ext] # Defaults to all
    weights: [400] # Defaults to all
    styles: [normal] # Defaults to all
```

The config will tell `fontsource` what to download and bundle into your flutter app. To ensure everything is downloaded, execute `dart run fontsource` after your config is modified. Also, make sure to run it whenever your repository is cloned. This will generate a local package in the `.fontsource` directory.

You can then import the `fontsource` package:

```dart
import 'package:fontsource/fontsource.dart';
```

Use the [`FontsourceTextStyle`](https://pub.dev/documentation/fontsource/latest/fontsource/FontsourceTextStyle-class.html) class to use a Fontsource font:

```dart
const Text(
  'Hello world!',
  style: FontsourceTextStyle(fontFamily: 'Alex Brush', fontSize: 30),
),
```

[`FontsourceTextStyle`](https://pub.dev/documentation/fontsource/latest/fontsource/FontsourceTextStyle-class.html) extends the [`TextStyle`](https://api.flutter.dev/flutter/painting/TextStyle-class.html) class, so any styling properties can be used to change the way the text looks.

## Use With Packages

To use this in a package, add a configuration like normal, but don't run the fontsource cli.

Packages with a fontsource configuration will automatically be included. To manually specify what packages should be scanned, provide an `include` key with a list of package names to scan.

## Fontsource API

The Fontsource API also has a dart interface that can be accessed through [`fontsource/api.dart`](https://pub.dev/documentation/fontsource/latest/api/api-library.html).
