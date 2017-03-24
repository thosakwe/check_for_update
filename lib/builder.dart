import 'dart:async';
import 'package:build/build.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec/pubspec.dart';
import 'check_for_update.dart';

class CheckForUpdateBuilder implements Builder {
  final String packageName, pubApiRoot;
  final Version currentVersion;

  CheckForUpdateBuilder(
      {this.packageName, this.pubApiRoot, this.currentVersion});

  @override
  List<AssetId> declareOutputs(AssetId inputId) =>
      [inputId.changeExtension('.update.g.dart')];

  @override
  Future build(BuildStep buildStep) async {
    var inputId = buildStep.inputId;
    var pubspec =
        new PubSpec.fromYamlString(await buildStep.readAsString(inputId));
    buildStep.writeAsString(
        inputId.changeExtension('.update.g.dart'),
        generateDartCode(pubspec,
            packageName: packageName,
            pubApiRoot: pubApiRoot,
            currentVersion: currentVersion));
  }
}
