import 'dart:convert';

import 'package:image_picker/image_picker.dart';

/// Captura fotos (câmera ou galeria) já reduzidas, como "data URI".
///
/// As fotos vão dentro do próprio documento do Firestore (limite de 1 MB por
/// documento), sem precisar do Cloud Storage. Ver docs/FIREBASE.md.
class PhotoService {
  PhotoService([ImagePicker? picker]) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  /// Tamanho máximo aceito após a compressão (bytes).
  static const maxBytes = 600 * 1024;

  /// Retorna `data:image/jpeg;base64,...` ou `null` se o usuário cancelar.
  Future<String?> pick({required bool fromCamera}) async {
    final picked = await _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 900,
      maxHeight: 900,
      imageQuality: 65,
    );
    if (picked == null) return null;
    final bytes = await picked.readAsBytes();
    if (bytes.length > maxBytes) {
      throw const PhotoTooLargeException();
    }
    return 'data:image/jpeg;base64,${base64Encode(bytes)}';
  }
}

class PhotoTooLargeException implements Exception {
  const PhotoTooLargeException();

  @override
  String toString() => 'Foto muito grande. Tente outra imagem.';
}
