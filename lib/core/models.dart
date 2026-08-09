/// Shared domain enums and constants.
library;

enum FlowLevel {
  spotting('Spotting'),
  light('Light'),
  medium('Medium'),
  heavy('Heavy');

  const FlowLevel(this.label);
  final String label;
}

enum CervicalMucus {
  dry('Dry'),
  sticky('Sticky'),
  creamy('Creamy'),
  eggWhite('Egg white');

  const CervicalMucus(this.label);
  final String label;
}

enum Libido {
  low('Low libido'),
  medium('Medium libido'),
  high('High libido');

  const Libido(this.label);
  final String label;
}

enum TrackingGoal {
  trackCycle('Track my cycle'),
  conceive('Trying to conceive'),
  pregnancy('I am pregnant');

  const TrackingGoal(this.label);
  final String label;
}

enum CyclePhase {
  menstrual('Menstrual'),
  follicular('Follicular'),
  fertile('Fertile window'),
  ovulation('Ovulation'),
  luteal('Luteal');

  const CyclePhase(this.label);
  final String label;
}

abstract class Symptoms {
  static const all = [
    'Cramps',
    'Headache',
    'Bloating',
    'Fatigue',
    'Acne',
    'Backache',
    'Tender breasts',
    'Nausea',
    'Cravings',
    'Insomnia',
  ];
}

abstract class Moods {
  static const all = [
    'Calm',
    'Happy',
    'Energetic',
    'Irritable',
    'Sad',
    'Anxious',
    'Mood swings',
  ];
}

/// Keys for the key-value settings table.
abstract class SettingsKeys {
  static const onboardingDone = 'onboarding_done';
  static const goal = 'goal';
  static const cycleLengthOverride = 'cycle_length_override';
  static const periodLengthOverride = 'period_length_override';
  static const lutealLength = 'luteal_length';
  static const pregnancyMode = 'pregnancy_mode';
  static const pregnancyLmp = 'pregnancy_lmp';
  static const notifyPeriod = 'notify_period';
  static const notifyFertile = 'notify_fertile';
  static const notifyOvulation = 'notify_ovulation';
  static const notifyLatePeriod = 'notify_late_period';
  static const pinHash = 'pin_hash';
  static const biometricEnabled = 'biometric_enabled';
  static const themeMode = 'theme_mode';
  static const lastBackupAt = 'last_backup_at';
}
