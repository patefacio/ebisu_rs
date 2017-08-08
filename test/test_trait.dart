library ebisu_rs.test_trait;

import 'package:ebisu_rs/trait.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>
// end <additional imports>

final Logger _logger = new Logger('test_trait');

// custom <library test_trait>
// end <library test_trait>

void main([List<String> args]) {
  if (args?.isEmpty ?? false) {
    Logger.root.onRecord.listen(
        (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
    Logger.root.level = Level.OFF;
  }
// custom <main>

  test('fn basics', () {
    var f1 = fn(#foobar, [
      parm(#a, mref(i32, 's'))..doc = 'The *i32* field called *a*',
      parm(#b, f64),
      parm(#c, string)
    ])
      ..typeParms = [#T1, #T2]
      ..doc = 'Function that does foobar'
      ..setAsRoot();

    print(f1.code);
    f1..returns = i32;

    print(f1.code);
  });

  test('trait basics', () {
    var t1 = trait(#woker)
      ..lifetimes = [#b]
      ..typeParms = [#t]
      ..functions = [
        fn(#doWork, [parm(#unit, mref(i32))]),
      ]
      ..setAsRoot();

    print(t1.code);
  });

// end <main>
}
