import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/food.dart';

/// Carrega a Tabela TACO completa empacotada no app (assets/data/taco.json).
class FoodRepository {
  const FoodRepository._();

  static const assetPath = 'assets/data/taco.json';

  static Future<List<Food>> loadTaco([AssetBundle? bundle]) async {
    final raw = await (bundle ?? rootBundle).loadString(assetPath);
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => Food.fromJson(e as Map<String, dynamic>)).toList(growable: false);
  }
}
