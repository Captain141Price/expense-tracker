/// Domain entity representing a single row in the [app_settings] table.
///
/// Only one row is ever stored (id = 1).
/// Balances are seeds set once during first launch — they are never
/// recalculated or updated. Running balances are always derived from
/// transactions at query time.
class AppSettings {
  const AppSettings({
    required this.id,
    required this.initialCash,
    required this.initialDigital,
    required this.isFirstLaunch,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final double initialCash;
  final double initialDigital;
  final bool isFirstLaunch;
  final String createdAt;
  final String updatedAt;

  AppSettings copyWith({
    double? initialCash,
    double? initialDigital,
    bool? isFirstLaunch,
    String? updatedAt,
  }) {
    return AppSettings(
      id: id,
      initialCash: initialCash ?? this.initialCash,
      initialDigital: initialDigital ?? this.initialDigital,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'AppSettings('
      'id: $id, '
      'initialCash: $initialCash, '
      'initialDigital: $initialDigital, '
      'isFirstLaunch: $isFirstLaunch)';
}
