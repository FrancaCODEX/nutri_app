import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'data/food_repository.dart';
import 'data/local_storage.dart';
import 'services/reminder_service.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR');

  final storageFuture = LocalStorage.open();
  final foodsFuture = FoodRepository.loadTaco();

  final state = AppState(
    storage: await storageFuture,
    foods: await foodsFuture,
    reminders: LocalReminderService(),
  );
  state.refreshReminders();

  runApp(AppStateScope(state: state, child: const NutriApp()));
}
