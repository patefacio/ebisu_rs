library ebisu_rs.test_ebisu_rs;

import 'package:ebisu_rs/ebisu_rs.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>
// end <additional imports>

final Logger _logger = new Logger('test_ebisu_rs');

// custom <library test_ebisu_rs>
// end <library test_ebisu_rs>

void main([List<String> args]) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
// custom <main>

  test('export test', () {
    var r = repo('repo')
      ..crates = [
        crate('crate')
          ..rootModule = (module('root_mod')
            ..modules = [module('sub_mod_1'), module('sub_mod_2')])
      ];

    print(r);
  });

// end <main>
}
