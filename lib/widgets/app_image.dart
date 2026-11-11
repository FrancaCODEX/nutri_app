import 'dart:io';

import 'package:flutter/material.dart';

/// Mostra uma imagem de URL (http) ou de arquivo local.
class AppImage extends StatelessWidget {
  const AppImage(this.source, {super.key, this.height, this.width, this.fit = BoxFit.cover});

  final String source;
  final double? height;
  final double? width;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    Widget fallback(BuildContext _, Object __, StackTrace? ___) => SizedBox(
          height: height,
          width: width,
          child: const Center(child: Icon(Icons.image_not_supported_outlined)),
        );
    return source.startsWith('http')
        ? Image.network(source, height: height, width: width, fit: fit, errorBuilder: fallback)
        : Image.file(File(source), height: height, width: width, fit: fit, errorBuilder: fallback);
  }
}
