library ebisu_rs.test_repo;

import 'package:ebisu_rs/repo.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>

import 'package:ebisu_rs/crate.dart';
import 'package:ebisu_rs/module.dart';

// end <additional imports>

final Logger _logger = new Logger('test_repo');

// custom <library test_repo>
// end <library test_repo>

void main([List<String> args]) {
  if (args?.isEmpty ?? false) {
    Logger.root.onRecord.listen(
        (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
    Logger.root.level = Level.OFF;
  }
// custom <main>

  test('repo creation', () {
    var r = repo('repo_1')
      ..crates = [
        crate('crate_1')
          ..rootModule = (module('root_mod')
            ..modules = [module('sub_mod_1'), module('sub_mod_2')])
      ];

    print(r);
  });

// end <main>
}
