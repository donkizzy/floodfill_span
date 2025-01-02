/// A widget that displays an image and allows flood fill operations on it.
///
/// The [FloodFillWidget] fetches an image from a given URL, displays it, and
/// allows the user to perform flood fill operations by tapping on the image.
/// The filled image is then updated and a callback is triggered with the new image.
///
/// The widget requires the following parameters:
///
/// - [newColor]: The color to be used for the flood fill operation.
/// - [onImageChanged]: A callback that is triggered when the image is updated after a flood fill operation.
/// - [imageUrl]: The URL of the image to be fetched and displayed.
/// - [loadingWidget]: An optional widget to be displayed while the image is being loaded.
/// - [width]: An optional width for the displayed image.
/// - [height]: An optional height for the displayed image.
///
/// Example usage:
///
/// ```dart
/// FloodFillWidget(
///   newColor: Colors.red,
///   onImageChanged: (image) {
///     // Handle the updated image
///   },
///   imageUrl: 'https://example.com/image.png',
///   loadingWidget: CircularProgressIndicator(),
///   width: 300,
///   height: 300,
/// )
/// ```
library;

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:floodfill_span/image_floodfill_span.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

class FloodFillWidget extends StatefulWidget {
  final Color newColor;
  final ValueChanged<ui.Image> onImageChanged;
  final String imageUrl;
  final Widget? loadingWidget;
  final double? width;
  final double? height;
  const FloodFillWidget(
      {super.key,
      required this.newColor,
      required this.onImageChanged,
      required this.imageUrl,
      this.loadingWidget,
      this.width,
      this.height});

  @override
  State<FloodFillWidget> createState() => _FloodFillWidgetState();
}

class _FloodFillWidgetState extends State<FloodFillWidget> {
  ui.Image? _image;

  @override
  void initState() {
    super.initState();
    _loadImage().then((image) {
      setState(() {
        _image = image;
      });
    });
  }

  Future<ui.Image> _loadImage() async {
    String url = widget.imageUrl;

    final response = await http.get(Uri.parse(url));

    final Uint8List data = response.bodyBytes;
    final ui.Codec codec =
        await ui.instantiateImageCodec(data.buffer.asUint8List());
    final ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  void _onTapDown(TapDownDetails details) async {
    try {
      final Offset localPosition = details.localPosition;
      final int x = localPosition.dx.toInt();
      final int y = localPosition.dy.toInt();
      final image =
          await ImageFloodFillSpanImpl(_image!).fill(x, y, widget.newColor);
      setState(() {
        _image = image;
      });
      widget.onImageChanged(_image!);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_image == null) {
      return widget.loadingWidget ??
          const Center(
            child: CircularProgressIndicator(),
          );
    }
    return FittedBox(
      child: GestureDetector(
        onTapDown: _onTapDown,
        child: CustomPaint(
          size: Size(widget.width ?? _image!.width.toDouble(),
              widget.height ?? _image!.height.toDouble()),
          painter: ImagePainter(_image!),
        ),
      ),
    );
  }
}

class ImagePainter extends CustomPainter {
  final ui.Image image;

  const ImagePainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(
        image, Offset.zero, Paint()..filterQuality = FilterQuality.high);
  }

  @override
  bool shouldRepaint(ImagePainter oldDelegate) => true;
}
