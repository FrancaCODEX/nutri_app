import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

/// Mostra uma imagem a partir de URL (http), "data URI" (base64) ou arquivo local.
class AppImage extends StatelessWidget {
  const AppImage(this.source, {super.key, this.height, this.width, this.fit = BoxFit.cover});

  final String source;
  final double? height;
  final double? width;
  final BoxFit fit;

  static final _cache = <String, MemoryImage>{};

  static ImageProvider providerFor(String source) {
    if (source.startsWith('http')) return NetworkImage(source);
    if (source.startsWith('data:')) {
      return _cache.putIfAbsent(source, () {
        final comma = source.indexOf(',');
        return MemoryImage(base64Decode(source.substring(comma + 1)));
      });
    }
    return FileImage(File(source));
  }

  @override
  Widget build(BuildContext context) {
    return Image(
      image: providerFor(source),
      height: height,
      width: width,
      fit: fit,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => SizedBox(
        height: height ?? 80,
        width: width,
        child: const Center(child: Icon(Icons.image_not_supported_outlined)),
      ),
    );
  }
}
