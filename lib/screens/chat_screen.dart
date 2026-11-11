import 'package:flutter/material.dart';

import '../models/chat_message.dart';
import '../state/app_state.dart';
import '../widgets/chat_view.dart';

/// Chat do paciente com a nutricionista (texto e fotos).
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Falar com a nutri')),
      body: ChatView(
        messages: state.messages,
        viewer: MessageAuthor.patient,
        emptyText: 'Mande sua dúvida para a nutricionista por aqui.',
        onSend: (text, image) async => state.sendMessage(text: text, imagePath: image),
      ),
    );
  }
}
