library ebisu_rs.test_crate;

import 'package:ebisu_rs/crate.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>

import 'package:ebisu_rs/module.dart';

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

  test('crate creation', () {
    var c = crate('crate')
      ..rootModule = (module('root_mod')
        ..modules = [module('sub_mod_1'), module('sub_mod_2')]);

    print(c);
  });

// end <main>
}
