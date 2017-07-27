library ebisu_rs.test_enumeration;

import 'package:ebisu_rs/enumeration.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>
// end <additional imports>

final Logger _logger = new Logger('test_enumeration');

// custom <library test_enumeration>
// end <library test_enumeration>

void main([List<String> args]) {
  if (args?.isEmpty ?? false) {
    Logger.root.onRecord.listen(
        (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
    Logger.root.level = Level.OFF;
  }
// custom <main>

test('c-style enum', () {
  var e = enum_('color', ['red','green','blue']);
  print(e.code);
});

// end <main>
}
