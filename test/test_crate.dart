library ebisu_rs.test_crate;

import 'package:ebisu_rs/crate.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>

import 'package:ebisu_rs/module.dart';
import 'package:ebisu/ebisu.dart';

// end <additional imports>

final Logger _logger = new Logger('test_crate');

// custom <library test_crate>

// end <library test_crate>

void main([List<String> args]) {
  if (args?.isEmpty ?? false) {
    Logger.root.onRecord.listen(
        (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
    Logger.root.level = Level.OFF;
  }
// custom <main>

  //Logger.root.level = Level.INFO;

  test('crate creation', () {
    var crate_ = crate('crate')
      ..rootModule = (module('root_mod')
        ..enums = [
          enum_('e1', ['a', 'b']),
          enum_('e2', ['c', 'd'])..derive = [Serialize]
        ]
        ..structs = [struct('s1'), struct('s2')]
        ..modules = [
          module('sub_mod_1')
            ..enums = [
              enum_('sm1_e1', ['a', 'b']),
              enum_('sm1_e2', ['c', 'd'])
            ]
            ..structs = [struct('sm1_s1'), struct('sm1_s2')],
          module('sub_mod_2')
            ..enums = [
              enum_('sm2_e1', ['a', 'b']),
              enum_('sm2_e2', ['c', 'd'])
            ]
            ..structs = [struct('sm2_s1'), struct('sm2_s2')],
        ])
      ..withCrateToml((crateToml) => crateToml.addDep("foo", "0.0.1"));

    final repo_ = repo('test_crate')..crates = [crate_];
    repo_.setAsRoot();
    final toml = darkMatter(crate_.toml);

    [
      'foo = "0.0.1"',
      'serde = "^1.0.11"',
    ].forEach((required) {
      expect(toml.contains(darkMatter(required)), true);
    });

    print(crate_);
    print(crate_.structs);
    print(crate_.enums);
    print(crate_.modules);
  });

// end <main>
}
