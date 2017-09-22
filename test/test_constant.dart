library ebisu_rs.test_constant;

import 'package:ebisu_rs/constant.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>
import 'package:ebisu_rs/module.dart';
import 'package:ebisu_rs/trait.dart';
import 'package:ebisu_rs/type.dart';
// end <additional imports>

final Logger _logger = new Logger('test_constant');

// custom <library test_constant>
// end <library test_constant>

void main([List<String> args]) {
  if (args?.isEmpty ?? false) {
    Logger.root.onRecord.listen(
        (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
    Logger.root.level = Level.OFF;
  }
// custom <main>

  test('constants in functions', () {
    var f = fn(#foo)
      ..constants = [new Const(#foo, i32)..value = 3]
      ..setAsRoot();

    expect(f.code.contains('const FOO: i32 = 3;'), true);
  });

  test('constants in modules', () {
    var m = module(#foo, inlineModule)
      ..constants = [new Const(#foo, i32)..value = 3]
      ..setAsRoot();
    expect(m.code.contains('const FOO: i32 = 3;'), true);
  });

// end <main>
}
