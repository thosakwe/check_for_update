import 'dart:async';
import 'package:build/build.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec/pubspec.dart';
import 'check_for_update.dart';

class CheckForUpdateBuilder implements Builder {
  final String packageName, pubApiRoot, subDirectory;
  final Version currentVersion;

  CheckForUpdateBuilder(
      {this.packageName,
      this.pubApiRoot,
      this.currentVersion,
      this.subDirectory});

  AssetId rename(AssetId inputId) {
    var result = inputId.changeExtension('.update.g.dart');

    if (subDirectory == null)
      return result;
    else {
      return new AssetId(inputId.package, p.join(subDirectory, result.path));
    }
  }

  @override
  List<AssetId> declareOutputs(AssetId inputId) => [rename(inputId)];

  @override
  Future build(BuildStep buildStep) async {
    var inputId = buildStep.inputId;
    var pubspec =
        new PubSpec.fromYamlString(await buildStep.readAsString(inputId));

    buildStep.writeAsString(
        rename(inputId),
        generateDartCode(pubspec,
            packageName: packageName,
            pubApiRoot: pubApiRoot,
            currentVersion: currentVersion));
  }
}
