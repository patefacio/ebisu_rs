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
      uv('green')
        ..doc = 'The color of grass'
        ..value = 22,
      'blue',
    ])
      ..derive = [Clone, Debug]
      ..doc = 'A c-style enum';
    print(e.code);
  });

  test('tuple variants', () {
    var e = enum_('tv_e', [
      tv('tv', [
        'i32',
        tf('[char;5]')..doc = 'Field is a str',
        'f64',
      ])
    ])
      ..doc = 'A tuple variant enum';
    print(e.code);
  });

  test('struct variants', () {
    var e = enum_('sv_e', [
      uv('bam')..value = 32,
      sv('sv', [
        'A',
      ])
        ..doc = 'An sv'
    ])
      ..derive = [Clone, Debug]
      ..doc = 'A struct variant enum';
    print(e.code);

    e.isPub = true;
    print(e.code);

    e.useSelf = true;
    print(e.code);
  });

// end <main>
}
