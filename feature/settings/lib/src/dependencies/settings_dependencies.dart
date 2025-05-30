import 'package:flutter/widgets.dart';
import 'package:key_value_database/key_value_database.dart';
import 'package:settings/settings.dart';
import 'package:settings/src/bloc/settings_bloc.dart';
import 'package:settings/src/bloc/settings_bloc_mediator.dart';
import 'package:settings/src/data/settings_datasource_local.dart';

class SettingsDependencies {
  const SettingsDependencies._({required this.settingsController});

  final SettingsController settingsController;

  static Future<SettingsDependencies> create(KeyValueDatabase database) async {
    final settingsDatasource = SettingsDatasourceLocal(database);
    final settingsBloc = SettingsBloc(
      settingsDatasource: settingsDatasource,
      initialState: SettingsStateIdle(
        settings: await settingsDatasource.getSettings() ?? SettingsModel.initial(),
      ),
    );

    final settingsMediator = SettingsBlocMediator(settingsBloc: settingsBloc);

    return SettingsDependencies._(settingsController: settingsMediator);
  }
}

/// Provides [SettingsDependenciesInherited] to the widget tree.
///
/// This widget is expected to be used by the Composition Root to provide
/// the dependencies of the settings feature to the widget tree.
class SettingsDependenciesInherited extends InheritedWidget {
  const SettingsDependenciesInherited({
    super.key,
    required this.dependencies,
    required super.child,
  });

  /// The dependencies of the settings feature.
  final SettingsDependencies dependencies;

  static SettingsDependencies of(BuildContext context) {
    final inherited = context.getInheritedWidgetOfExactType<SettingsDependenciesInherited>();
    if (inherited == null) {
      throw FlutterError('SettingsDependencies not found in context');
    }

    return inherited.dependencies;
  }

  @override
  bool updateShouldNotify(SettingsDependenciesInherited oldWidget) {
    // Dependencies are not expected to change, so we return false
    return false;
  }
}
