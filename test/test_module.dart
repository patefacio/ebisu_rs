library ebisu_rs.test_module;

import 'package:ebisu_rs/module.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>
// end <additional imports>

final Logger _logger = new Logger('test_module');

// custom <library test_module>
// end <library test_module>

void main([List<String> args]) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
// custom <main>

  test('create module', () {
    var m = module('foo');
  });

// end <main>
}
