/// Antrenman modu türlerini temsil eden enum.
enum WorkoutMode {
  emom,
  amrap,
  tabata,
  forTime,
  custom,
}

extension WorkoutModeX on WorkoutMode {
  /// Veritabanı ve paylaşım için kullanılan büyük harf string temsili.
  String get displayName {
    switch (this) {
      case WorkoutMode.emom:
        return 'EMOM';
      case WorkoutMode.amrap:
        return 'AMRAP';
      case WorkoutMode.tabata:
        return 'TABATA';
      case WorkoutMode.forTime:
        return 'FOR TIME';
      case WorkoutMode.custom:
        return 'CUSTOM';
    }
  }

  /// Veritabanındaki string değerinden enum değerine güvenli dönüşüm.
  /// Bilinmeyen değerler [WorkoutMode.custom] olarak döner.
  static WorkoutMode fromString(String value) {
    switch (value.trim().toUpperCase()) {
      case 'EMOM':
        return WorkoutMode.emom;
      case 'AMRAP':
        return WorkoutMode.amrap;
      case 'TABATA':
        return WorkoutMode.tabata;
      case 'FOR TIME':
        return WorkoutMode.forTime;
      default:
        return WorkoutMode.custom;
    }
  }
}
