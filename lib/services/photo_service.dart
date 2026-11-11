import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Captura fotos (câmera ou galeria) e guarda uma cópia na pasta do app.
class PhotoService {
  PhotoService([ImagePicker? picker]) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  /// Retorna o caminho da foto salva, ou `null` se o usuário cancelar.
  Future<String?> pick({required bool fromCamera, String folder = 'chat_photos'}) async {
    final picked = await _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 80,
    );
    if (picked == null) return null;

    final dir = Directory('${(await getApplicationDocumentsDirectory()).path}/$folder');
    await dir.create(recursive: true);
    final dest = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    await File(picked.path).copy(dest);
    return dest;
  }
}
