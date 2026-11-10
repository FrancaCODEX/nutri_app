import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/chat_message.dart';
import '../services/photo_service.dart';
import '../state/app_state.dart';

/// Chat direto com a nutricionista (texto e fotos).
///
/// Nesta versão as mensagens ficam salvas no aparelho. A entrega para a
/// nutricionista e as notificações de resposta chegam com o Firebase
/// (ver docs/ROADMAP.md).
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _photos = PhotoService();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    AppStateScope.read(context).sendMessage(text: _controller.text);
    _controller.clear();
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
      final path = await _photos.pick(fromCamera: fromCamera);
      if (path == null || !mounted) return;
      AppStateScope.read(context).sendMessage(text: _controller.text, imagePath: path);
      _controller.clear();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir a câmera/galeria.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = AppStateScope.of(context).messages.reversed.toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Falar com a nutri')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (_, i) => _Bubble(message: messages[i]),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Enviar foto',
                    onPressed: _attachPhoto,
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
                  IconButton(tooltip: 'Enviar', onPressed: _send, icon: const Icon(Icons.send)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final ChatMessage message;

  void _openPhoto(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white),
        body: Center(
          child: InteractiveViewer(child: Image.file(File(message.imagePath!))),
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final mine = message.author == MessageAuthor.patient;
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
                  child: Image.file(
                    File(message.imagePath!),
                    width: 240,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox(
                      width: 240,
                      height: 80,
                      child: Center(child: Text('Foto indisponível')),
                    ),
                  ),
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
