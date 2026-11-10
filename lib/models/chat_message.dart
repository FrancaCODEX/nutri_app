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

  /// Caminho local da foto enviada (ex.: foto do prato).
  final String? imagePath;

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String,
        author: MessageAuthor.values.byName(json['author'] as String),
        sentAt: DateTime.parse(json['sentAt'] as String),
        text: json['text'] as String?,
        imagePath: json['imagePath'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'author': author.name,
        'sentAt': sentAt.toIso8601String(),
        'text': text,
        'imagePath': imagePath,
      };
}
