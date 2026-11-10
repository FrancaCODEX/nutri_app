enum MessageAuthor { patient, nutritionist }

/// Mensagem do chat direto entre paciente e nutricionista.
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.author,
    required this.sentAt,
    this.text,
    this.imagePath,
  }) : assert(text != null || imagePath != null);

  final String id;
  final MessageAuthor author;
  final DateTime sentAt;
  final String? text;

  /// Caminho/URL da foto enviada (ex.: foto do prato).
  final String? imagePath;
}
