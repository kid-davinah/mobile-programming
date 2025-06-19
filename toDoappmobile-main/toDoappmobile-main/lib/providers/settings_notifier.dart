import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsState {
  final bool notificationsEnabled;
  final bool autoBackupEnabled;
  final String language;
  final bool showCompletedTodos;
  final bool sortByDueDate;
  final int reminderTimeMinutes;

  SettingsState({
    this.notificationsEnabled = true,
    this.autoBackupEnabled = false,
    this.language = 'en',
    this.showCompletedTodos = true,
    this.sortByDueDate = true,
    this.reminderTimeMinutes = 30,
  });

  SettingsState copyWith({
    bool? notificationsEnabled,
    bool? autoBackupEnabled,
    String? language,
    bool? showCompletedTodos,
    bool? sortByDueDate,
    int? reminderTimeMinutes,
  }) {
    return SettingsState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
      language: language ?? this.language,
      showCompletedTodos: showCompletedTodos ?? this.showCompletedTodos,
      sortByDueDate: sortByDueDate ?? this.sortByDueDate,
      reminderTimeMinutes: reminderTimeMinutes ?? this.reminderTimeMinutes,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState());

  void toggleNotifications() {
    state = state.copyWith(notificationsEnabled: !state.notificationsEnabled);
  }

  void toggleAutoBackup() {
    state = state.copyWith(autoBackupEnabled: !state.autoBackupEnabled);
  }

  void setLanguage(String lang) {
    state = state.copyWith(language: lang);
  }

  void toggleShowCompleted() {
    state = state.copyWith(showCompletedTodos: !state.showCompletedTodos);
  }

  void toggleSortByDueDate() {
    state = state.copyWith(sortByDueDate: !state.sortByDueDate);
  }

  void setReminderTime(int minutes) {
    state = state.copyWith(reminderTimeMinutes: minutes);
  }

  void resetToDefaults() {
    state = SettingsState();
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(),
); 