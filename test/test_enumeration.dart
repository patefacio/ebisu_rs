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
    var e = enum_('color', [
      'red',
      uv('green'),
      'blue',
    ]);
    print(e.code);
  });

  test('tuple variants', () {
    var e = enum_('tv_e', [
      tv('tv', [
        'A',
        tf('str')..doc = 'Field is a str',
        'C',
      ])
    ]);
    print(e.code);
  });

  test('struct variants', () {
    var e = enum_('sv_e', [
      sv('sv', [
        'A',
      ])
        ..doc = 'An sv'
    ]);
    print(e.code);
  });

// end <main>
}
