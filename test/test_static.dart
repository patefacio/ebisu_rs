library ebisu_rs.test_static;

import 'package:ebisu_rs/static.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>
import 'package:ebisu_rs/module.dart';
import 'package:ebisu_rs/trait.dart';
import 'package:ebisu_rs/type.dart';
// end <additional imports>

final Logger _logger = new Logger('test_static');

// custom <library test_static>
// end <library test_static>

void main([List<String> args]) {
  if (args?.isEmpty ?? false) {
    Logger.root.onRecord.listen(
        (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
    Logger.root.level = Level.OFF;
  }
// custom <main>

  test('statics in functions', () {
    var f = fn(#foo)
      ..statics = [static(#foo, i32)..value = 3..doc = 'Is static foo']
      ..setAsRoot();

    expect(f.code.contains('/// Is static foo'), true);
    expect(
        f.code.contains(
            new RegExp(r'\n\s*static FOO: i32 = 3;', multiLine: true)),
        true);

    f = fn(#foo)
      ..statics = [static(#foo, i32)..value = 3..isPub = true]
      ..setAsRoot();

    expect(f.code.contains('pub static FOO: i32 = 3;'), true);
  });

  test('statics in modules', () {
    var m = module(#foo, inlineModule)
      ..statics = [static(#foo, i32)..value = 3]
      ..setAsRoot();

    expect(
        m.code.contains(
            new RegExp(r'\n?\s*static FOO: i32 = 3;', multiLine: true)),
        true);

    m.statics.first.isPub = true;
    expect(m.code.contains('pub static FOO: i32 = 3;'), true);
  });

// end <main>
}
