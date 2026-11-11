import 'package:flutter/material.dart';

import 'chat_screen.dart';
import 'diary_screen.dart';
import 'meal_plan_screen.dart';
import 'recipes_screen.dart';
import 'today_screen.dart';

/// Navegação principal com as cinco áreas do app.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  static const _mealPlanTab = 1;
  static const _diaryTab = 3;

  int _index = 0;

  void _go(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final pages = [
      TodayScreen(onOpenMealPlan: () => _go(_mealPlanTab), onOpenDiary: () => _go(_diaryTab)),
      const MealPlanScreen(),
      const RecipesScreen(),
      const DiaryScreen(),
      const ChatScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _go,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Hoje'),
          NavigationDestination(icon: Icon(Icons.restaurant_menu), label: 'Cardápio'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Receitas'),
          NavigationDestination(icon: Icon(Icons.edit_note), label: 'Diário'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Chat'),
        ],
      ),
    );
  }
}
