import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/chat_message.dart';
import '../services/photo_service.dart';
import 'app_image.dart';

/// Conversa (lista de mensagens + campo de envio), usada pelo paciente e pela
/// nutricionista. [viewer] indica quem está olhando (suas mensagens à direita).
class ChatView extends StatefulWidget {
  const ChatView({
    super.key,
    required this.messages,
    required this.viewer,
    required this.onSend,
    this.emptyText = 'Nenhuma mensagem ainda.',
  });

  final List<ChatMessage> messages;
  final MessageAuthor viewer;
  final Future<void> Function(String? text, String? image) onSend;
  final String emptyText;

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final _controller = TextEditingController();
  final _photos = PhotoService();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send({String? image}) async {
    final text = _controller.text.trim();
    if (text.isEmpty && image == null) return;
    setState(() => _sending = true);
    try {
      await widget.onSend(text.isEmpty ? null : text, image);
      _controller.clear();
    } catch (_) {
      _snack('Não foi possível enviar. Verifique a internet.');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _snack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _attachPhoto() async {
    final fromCamera = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Tirar foto'),
              onTap: () => Navigator.pop(context, true),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Escolher da galeria'),
              onTap: () => Navigator.pop(context, false),
            ),
          ],
        ),
      ),
    );
    if (fromCamera == null) return;
    try {
      final image = await _photos.pick(fromCamera: fromCamera);
      if (image != null) await _send(image: image);
    } on PhotoTooLargeException catch (e) {
      _snack(e.toString());
    } catch (_) {
      _snack('Não foi possível abrir a câmera/galeria.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = widget.messages.reversed.toList();
    return Column(
      children: [
        Expanded(
          child: messages.isEmpty
              ? Center(child: Text(widget.emptyText))
              : ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (_, i) => _Bubble(
                    message: messages[i],
                    mine: messages[i].author == widget.viewer,
                  ),
                ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Enviar foto',
                  onPressed: _sending ? null : _attachPhoto,
                  icon: const Icon(Icons.add_a_photo_outlined),
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(hintText: 'Escreva sua mensagem'),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                _sending
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : IconButton(tooltip: 'Enviar', onPressed: _send, icon: const Icon(Icons.send)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.mine});

  final ChatMessage message;
  final bool mine;

  void _openPhoto(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white),
        body: Center(child: InteractiveViewer(child: AppImage(message.imagePath!, fit: BoxFit.contain))),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(10),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: mine ? colors.primaryContainer : colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (message.imagePath != null)
              GestureDetector(
                onTap: () => _openPhoto(context),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AppImage(message.imagePath!, width: 240),
                ),
              ),
            if (message.text != null)
              Padding(
                padding: EdgeInsets.only(top: message.imagePath != null ? 6 : 0),
                child: Align(alignment: Alignment.centerLeft, child: Text(message.text!)),
              ),
            const SizedBox(height: 2),
            Text(DateFormat('dd/MM HH:mm').format(message.sentAt),
                style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
