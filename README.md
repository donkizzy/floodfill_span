<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# FloodFill Span

A Dart package that provides efficient flood fill algorithms for image processing and painting applications.

![](https://github.com/user-attachments/assets/16e24336-8c45-4d6c-acf8-8069e6e69cfb
)

## Features

- Fast flood fill implementation using span-based algorithm
- Support for custom boundary conditions
- Works with Flutter's Canvas and Paint classes
- Memory efficient for large areas
- Customizable fill patterns and colors

## Getting started

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  floodfill_span: ^0.0.1
```

## Usage

Import the package and use the flood fill algorithm:

```
FloodFillWidget(
newColor: selectedColor,
onImageChanged: (image) {
    _image = image;
 },
imageUrl: "",
)
```

See the `example` folder for more detailed examples.

## Additional information

Package home: GitHub Repository
Bug reports and feature requests: Issue Tracker
Documentation: API Reference

## License

This project is licensed under the MIT License - see the `LICENSE` file for details.
