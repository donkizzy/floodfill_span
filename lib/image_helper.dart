import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

Future<ByteData?> imageToBytes(ui.Image image) async {
  final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  return bytes;
}

Future<ui.Image> imageFromBytes(ByteData bytes, int imageWidth, int imageHeight) {
  final Completer<ui.Image> completer = Completer();
  ui.decodeImageFromPixels(
    bytes.buffer.asUint8List(),
    imageWidth,
    imageHeight,
    ui.PixelFormat.rgba8888,
        (img) {
      completer.complete(img);
    },
  );
  return completer.future;
}

void setPixelColor({
  required int x,
  required int y,
  required ByteData bytes,

  // for correct representation of color bytes' coordinates
  // in an array of image bytes
  required int imageWidth,
  required ui.Color newColor,
}) {
  bytes.setUint32(
    (x + y * imageWidth) * 4, // offset
    colorToIntRGBA(newColor), // value
  );
}

ui.Color getPixelColor({
  required ByteData bytes,
  required int x,
  required int y,
  required int imageWidth,
}) {
  final uint32 = bytes.getUint32((x + y * imageWidth) * 4);
  return colorFromIntRGBA(uint32);
}

int colorToIntRGBA(ui.Color color) {
  // Extract ARGB components
  int a = (color.value >> 24) & 0xFF;
  int r = (color.value >> 16) & 0xFF;
  int g = (color.value >> 8) & 0xFF;
  int b = color.value & 0xFF;

  // Convert to RGBA and combine into a single integer
  return (r << 24) | (g << 16) | (b << 8) | a;
}

ui.Color colorFromIntRGBA(int uint32Rgba) {
  // Extract RGBA components
  int r = (uint32Rgba >> 24) & 0xFF;
  int g = (uint32Rgba >> 16) & 0xFF;
  int b = (uint32Rgba >> 8) & 0xFF;
  int a = uint32Rgba & 0xFF;

  // Convert to ARGB format and create a Color object
  return ui.Color.fromARGB(a, r, g, b);
}

bool isAlmostSameColor({
  required ui.Color pixelColor,
  required ui.Color checkColor,
  required int imageWidth,
}) {
  const int threshold = 50;
  final int rDiff = (pixelColor.red - checkColor.red).abs();
  final int gDiff = (pixelColor.green - checkColor.green).abs();
  final int bDiff = (pixelColor.blue - checkColor.blue).abs();
  return rDiff < threshold && gDiff < threshold && bDiff < threshold;
}
