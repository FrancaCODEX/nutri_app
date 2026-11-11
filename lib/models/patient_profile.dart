import 'meal_plan.dart';

/// Cadastro do paciente (documento patients/{uid}).
class PatientProfile {
  const PatientProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.mealPlan,
    this.createdAt,
    this.lastSeenAt,
    this.lastPatientMessageAt,
    this.nutriReadAt,
  });

  final String uid;
  final String name;
  final String email;
  final MealPlan? mealPlan;
  final DateTime? createdAt;
  final DateTime? lastSeenAt;
  final DateTime? lastPatientMessageAt;
  final DateTime? nutriReadAt;

  /// Há mensagem do paciente que a nutricionista ainda não abriu.
  bool get hasUnread =>
      lastPatientMessageAt != null &&
      (nutriReadAt == null || lastPatientMessageAt!.isAfter(nutriReadAt!));
}
