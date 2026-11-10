import 'package:flutter/material.dart';

import 'chat_screen.dart';
import 'diary_screen.dart';
import 'meal_plan_screen.dart';
import 'recipes_screen.dart';

/// Navegação principal com as quatro áreas do app.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _pages = [
    MealPlanScreen(),
    RecipesScreen(),
    DiaryScreen(),
    ChatScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.restaurant_menu), label: 'Cardápio'),
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'Receitas'),
          NavigationDestination(icon: Icon(Icons.edit_note), label: 'Diário'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
        ],
      ),
    );
  }
}
