/// A class that implements the flood fill algorithm for an image.
///
/// The flood fill algorithm starts at a given point and spreads outwards,
/// filling all connected pixels that have the same color as the starting point
/// with a new color.
///
/// The algorithm processes the image in smaller chunks to avoid memory spikes.
///
/// Example usage:
/// ```dart
/// final ui.Image image = ...; // Load your image
/// final ImageFloodFillSpanImpl floodFill = ImageFloodFillSpanImpl(image);
/// final ui.Image? filledImage = await floodFill.fill(startX, startY, newColor);
/// ```
///
/// The `fill` method takes the starting coordinates (`startX`, `startY`) and the
/// new color (`newColor`) to fill the connected area.
///
/// The `chunkSize` constant defines the number of pixels to process in each chunk.
///
/// The `_isInside` method checks if a pixel is inside the image boundaries and
/// has the target color.
library;

import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:floodfill_span/image_helper.dart';

class ImageFloodFillSpanImpl {
  final ui.Image image;
  ImageFloodFillSpanImpl(this.image);

  static const int chunkSize = 1000; // Process in smaller chunks

  Future<ui.Image?> fill(int startX, int startY, ui.Color newColor) async {
    ByteData? byteData = await imageToBytes(image);
    if (byteData == null) return null;

    int width = image.width;
    int height = image.height;
    ui.Color targetColor =
        getPixelColor(bytes: byteData, x: startX, y: startY, imageWidth: width);

    final queue = Queue<List<int>>();
    queue.addLast([startX, startX, startY, 1]);
    queue.addLast([startX, startX, startY - 1, -1]);

    int processedPixels = 0;

    while (queue.isNotEmpty) {
      // Process in chunks to avoid memory spikes
      if (processedPixels > chunkSize) {
        // Allow garbage collection to run
        await Future.delayed(Duration.zero);
        processedPixels = 0;
      }

      var tuple = queue.removeFirst();
      var x1 = tuple[0];
      var x2 = tuple[1];
      var y = tuple[2];
      var dy = tuple[3];

      var nx = x1;
      if (_isInside(nx, y, width, height, byteData, targetColor)) {
        while (_isInside(nx - 1, y, width, height, byteData, targetColor)) {
          nx--;
        }
        for (int i = nx; i < x1; i++) {
          setPixelColor(
              x: i,
              y: y,
              bytes: byteData,
              imageWidth: width,
              newColor: newColor);
          processedPixels++;
        }
        if (nx < x1) {
          queue.addLast([nx, x1 - 1, y - dy, -dy]);
        }
      }

      while (x1 <= x2) {
        while (_isInside(x1, y, width, height, byteData, targetColor)) {
          x1++;
          processedPixels++;
        }
        for (int i = nx; i < x1; i++) {
          setPixelColor(
              x: i,
              y: y,
              bytes: byteData,
              imageWidth: width,
              newColor: newColor);
        }
        if (x1 > nx) {
          queue.addLast([nx, x1 - 1, y + dy, dy]);
        }
        if (x1 - 1 > x2) {
          queue.addLast([x2 + 1, x1 - 1, y - dy, -dy]);
        }
        x1++;
        while (x1 < x2 &&
            !_isInside(x1, y, width, height, byteData, targetColor)) {
          x1++;
        }
        nx = x1;
      }
    }

    return imageFromBytes(byteData, width, height);
  }

  bool _isInside(int x, int y, int width, int height, ByteData bytes,
      ui.Color targetColor) {
    if (x < 0 || x >= width || y < 0 || y >= height) return false;
    ui.Color pixelColor =
        getPixelColor(bytes: bytes, x: x, y: y, imageWidth: width);
    return isAlmostSameColor(
        pixelColor: pixelColor, checkColor: targetColor, imageWidth: width);
  }
}
