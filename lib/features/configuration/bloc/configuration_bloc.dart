import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:guildwars2_companion/features/configuration/models/configuration.dart';
import 'package:guildwars2_companion/features/configuration/repositories/configuration.dart';
import 'package:meta/meta.dart';

part 'configuration_event.dart';
part 'configuration_state.dart';

class ConfigurationBloc extends Bloc<ConfigurationEvent, ConfigurationState> {
  final ConfigurationRepository configurationRepository;

  ConfigurationBloc({
    this.configurationRepository
  }): super(ConfigurationState(
    configuration: configurationRepository.getConfiguration()
  ));

  @override
  Stream<ConfigurationState> mapEventToState(
    ConfigurationEvent event,
  ) async* {
    if (event is ChangeThemeEvent) {
      await configurationRepository.changeTheme(event.theme);
    } else if (event is ChangeLanguageEvent) {
      await configurationRepository.changeLanguage(event.language);
    } else if (event is ChangeTimeNotationEvent) {
      await configurationRepository.changeTimeNotation(event.notation24Hours);
    }

    yield this.getConfiguration();
  }

  ConfigurationState getConfiguration() {
    return ConfigurationState(
      configuration: this.configurationRepository.getConfiguration()
    );
  }
}
