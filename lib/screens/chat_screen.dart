import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/chat_message.dart';
import '../state/app_state.dart';

/// Chat direto com a nutricionista (texto e fotos).
///
/// O envio de fotos usa o pacote image_picker, que será adicionado na
/// fase 2 junto com o Firebase Storage (ver docs/ROADMAP.md).
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    AppStateScope.of(context).sendMessage(text: _controller.text);
    _controller.clear();
  }

  void _attachPhoto() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Envio de fotos disponível na próxima versão.')),
    );
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
                  IconButton(onPressed: _attachPhoto, icon: const Icon(Icons.photo_camera)),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Escreva sua mensagem',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  IconButton(onPressed: _send, icon: const Icon(Icons.send)),
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
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (message.imagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(File(message.imagePath!), width: 220),
              ),
            if (message.text != null)
              Align(alignment: Alignment.centerLeft, child: Text(message.text!)),
            Text(DateFormat.Hm().format(message.sentAt),
                style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
