part of 'settings_bloc.dart';

@immutable
sealed class SettingsEvent {}

final class GoalSetting extends SettingsEvent {
  final Duration goal;
  GoalSetting({required this.goal});
}

final class RestSetting extends SettingsEvent {
  final Duration rest;
  RestSetting({required this.rest});
}
