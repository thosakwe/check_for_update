# check_for_update

[![version 1.0.0](https://img.shields.io/badge/pub-1.0.0-brightgreen.svg)](https://pub.dartlang.org/packages/check_for_update)

Generates Dart code to automatically check for a new version of the current package. Your project should depend on `http`. The output code is platform-independent.

One final field is generated: `PACKAGE_VERSION` - The package's active version.
Two methods are generated:
* `fetchCurrentVersion`: Asks the Pub API what the latest version of the package is.
* `checkForUpdate`: Compares `PACKAGE_VERSION` to the result of `fetchCurrentVersion` and
returns `null` if no update is available. Otherwise, the new version will be returned.

# Usage
Generate from the project `pubspec.yaml`:

```dart
import 'package:build_runner/build_runner.dart';
import 'package:check_for_update/builder.dart';

final PhaseGroup phaseGroup = new PhaseGroup.singleAction(
    new CheckForUpdateBuilder(),
    new InputSet('example', const ['pubspec.yaml']));
```

## Overrides
Specifying a specific package name to scan for updates:

```dart
new CheckForUpdateBuilder(packageName: 'shelf')
```

Specifying a custom Pub API URL:

```dart
new CheckForUpdateBuilder(pubApiRoot: 'https://foo.bar/pub-api')
```

Specifying a specific version to check against:

```dart
new CheckForUpdateBuilder(currentVersion: new Version(1, 2, 0, pre: 'alpha.6'))
```

