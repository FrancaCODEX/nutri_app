import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'data/cloud_repository.dart';
import 'data/food_repository.dart';
import 'data/local_storage.dart';
import 'firebase_options.dart';
import 'screens/auth/auth_gate.dart';
import 'services/auth_service.dart';
import 'services/reminder_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final storageFuture = LocalStorage.open();
  final foodsFuture = FoodRepository.loadTaco();

  runApp(NutriApp(
    home: AuthGate(
      auth: AuthService(),
      repo: CloudRepository(),
      storage: await storageFuture,
      foods: await foodsFuture,
      reminders: LocalReminderService(),
    ),
  ));
}
