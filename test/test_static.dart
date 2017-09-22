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
      ..statics = [static(#foo, i32)..value = 3]
      ..setAsRoot();

    expect(f.code.contains('static FOO: i32 = 3;'), true);
  });

  test('statics in modules', () {
    var m = module(#foo, inlineModule)
      ..statics = [static(#foo, i32)..value = 3]
      ..setAsRoot();
    expect(m.code.contains('static FOO: i32 = 3;'), true);
  });

// end <main>
}
