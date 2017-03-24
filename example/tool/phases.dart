import 'package:build_runner/build_runner.dart';
import 'package:check_for_update/builder.dart';

final PhaseGroup phaseGroup = new PhaseGroup.singleAction(
    new CheckForUpdateBuilder(packageName: 'angel_cli', subDirectory: 'lib'),
    new InputSet('example', const ['pubspec.yaml']));
