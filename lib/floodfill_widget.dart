import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:floodfill_span/image_floodfill_span.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;


class FloodFillRaster extends StatefulWidget {
  final Color newColor;
  final ValueChanged<ui.Image> onImageChanged;
  const FloodFillRaster({super.key, required this.newColor, required this.onImageChanged});

  @override
  State<FloodFillRaster> createState() => _FloodFillRasterState();
}

class _FloodFillRasterState extends State<FloodFillRaster> {
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
    const url =
        'https://sun9-77.userapi.com/impg/BiGYCxYxSuZgeILSzA0dtPcNC7935fdhpW36rg/e3jk6CqTwkw.jpg?size=1372x1372&quality=95&sign=2afb3d42765f8777879e06c314345303&type=album';

    final response = await http.get(Uri.parse(url));

    final Uint8List data = response.bodyBytes;
    final ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  void _onTapDown(TapDownDetails details) async {
    try{
      final Offset localPosition = details.localPosition;
      final int x = localPosition.dx.toInt();
      final int y = localPosition.dy.toInt();
      final image = await ImageFloodFillSpanImpl(_image!).fill(x, y, widget.newColor);
      setState(() {
        _image = image;
      });
      widget.onImageChanged(_image!);
    }catch(e){
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_image == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return FittedBox(
      child: GestureDetector(
        onTapDown: _onTapDown,
        child: CustomPaint(
          size: Size(_image!.width.toDouble(), _image!.height.toDouble()),
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
    canvas.drawImage(image, Offset.zero, Paint()..filterQuality = FilterQuality.high);
  }

  @override
  bool shouldRepaint(ImagePainter oldDelegate) => true;
}