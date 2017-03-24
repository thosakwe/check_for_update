import 'package:code_builder/code_builder.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec/pubspec.dart';

final ParameterBuilder _PARAM_CLIENT =
    parameter('client', [new TypeBuilder('http.BaseClient')]);
final TypeBuilder _TYPE_VERSION = new TypeBuilder('Version');

String generateDartCode(PubSpec pubspec,
        {String packageName, Version currentVersion, String pubApiRoot}) =>
    prettyToSource(generateDartLibrary(pubspec,
            packageName: packageName,
            currentVersion: currentVersion,
            pubApiRoot: pubApiRoot)
        .buildAst());

LibraryBuilder generateDartLibrary(PubSpec pubspec,
    {String packageName, Version currentVersion, String pubApiRoot}) {
  String name = (packageName?.isNotEmpty == true ? packageName : pubspec.name),
      apiRoot = (pubApiRoot?.isNotEmpty == true
          ? pubApiRoot
          : 'https://pub.dartlang.org/api');
  var version = currentVersion ?? pubspec.version;

  var lib = new LibraryBuilder();
  lib.addDirectives([
    new ImportBuilder('dart:async'),
    new ImportBuilder('dart:convert'),
    new ImportBuilder('package:http/src/base_client.dart', prefix: 'http'),
    new ImportBuilder('package:pub_semver/pub_semver.dart')
  ]);

  // final Version PACKAGE_VERSION = new Version(major, minor, patch);
  var named = {};

  if (version.isPreRelease)
    named['pre'] = literal(version.preRelease.join('.'));
  if (version.build?.isNotEmpty == true)
    named['build'] = literal(version.build.join('.'));

  lib.addMember(varFinal('PACKAGE_VERSION',
      type: _TYPE_VERSION,
      value: _TYPE_VERSION.newInstance(
          [version.major, version.minor, version.patch].map(literal),
          named: named)));

  lib.addMember(generateFetchCurrentVersion(name, apiRoot));
  lib.addMember(generateCheckForUpdate());

  return lib;
}

MethodBuilder generateFetchCurrentVersion(
    String packageName, String pubApiRoot) {
  /*
  Future<Version> fetchCurrentVersion(http.BaseClient client) async {
    var response = await client.get('$pubApiRoot/packages/$packageName');
    var json = JSON.decode(response.body) as Map;

    if (!json.containsKey('latest')
      || !json['latest'].containsKey('pubspec')
      || !json['latest']['pubspec'].containsKey('version'))
      throw new StateError('GET $pubApiRoot/packages/$packageName returned an invalid response.');
    return new Version.parse(json['latest']['pubspec']['version']);
  }
  */
  String url = '$pubApiRoot/packages/$packageName';

  // Future<Version> fetchCurrentVersion(http.BaseClient client) async {}
  var meth = new MethodBuilder('fetchCurrentVersion',
      modifier: MethodModifier.asAsync,
      returnType: new TypeBuilder('Future', genericTypes: [_TYPE_VERSION]))
    ..addPositional(_PARAM_CLIENT);

  // var response = await client.get('$pubApiRoot/packages/$packageName');
  meth.addStatement(varField('response',
      value: reference('client').invoke('get', [literal(url)]).asAwait()));

  // var json = JSON.decode(response.body) as Map;
  meth.addStatement(varField('json',
      value: reference('JSON')
          .invoke('decode', [reference('response').property('body')]).castAs(
              new TypeBuilder('Map'))));

  var json = reference('json');
  var cond = (json.invoke('containsKey', [literal('latest')]).negate())
      .or((json[literal('latest')]
          .invoke('containsKey', [literal('pubspec')]).negate()))
      .or((json[literal('latest')][literal('pubspec')]
          .invoke('containsKey', [literal('version')]).negate()));

  meth.addStatement(ifThen(cond, [
    new TypeBuilder('StateError').newInstance(
        [literal('GET $url returned an invalid pub API response.')]).asThrow()
  ]));

  meth.addStatement(_TYPE_VERSION.newInstance(
      [json[literal('latest')][literal('pubspec')][literal('version')]],
      constructor: 'parse').asReturn());

  return meth;
}

MethodBuilder generateCheckForUpdate() {
  /*
  Future<Version> checkForUpdate(http.BaseClient client) async {
    var current = await fetchCurrentVersion(client);
    if (PACKAGE_VERSION.compareTo(current) < 0) return current;
    return null;
  }
  */

  // Future<Version> checkForUpdate(http.BaseClient client) async {}
  var meth = new MethodBuilder('checkForUpdate',
      modifier: MethodModifier.asAsync,
      returnType: new TypeBuilder('Future', genericTypes: [_TYPE_VERSION]))
    ..addPositional(_PARAM_CLIENT);

  meth.addStatement(varField('current',
      value: reference('fetchCurrentVersion')
          .call([reference('client')]).asAwait()));

  meth.addStatement(ifThen(
      reference('PACKAGE_VERSION').invoke('compareTo', [reference('current')]) <
          literal(0),
      [reference('current').asReturn()]));

  meth.addStatement(literal(null).asReturn());

  return meth;
}
