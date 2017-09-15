library ebisu_rs.test_lifetime_elision;

import 'package:ebisu_rs/trait.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>
// end <additional imports>

final Logger _logger = new Logger('test_lifetime_elision');

// custom <library test_lifetime_elision>
// end <library test_lifetime_elision>

void main([List<String> args]) {
  if (args?.isEmpty ?? false) {
    Logger.root.onRecord.listen(
        (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
    Logger.root.level = Level.OFF;
  }
// custom <main>

  test('one input ref triggers elision', () {
    var functions = [
      fn(#f, [parm(#a, ref(i32))]),
      fn(#f, [selfRef, parm(#b, ref(i32))]),
      fn(#f, [parm(#b, ref(i32))])..returns = ref(i32),
    ].map((f) => f..setAsRoot());

    // No lifetimes in these cases because of elision rules
    expect(functions.any((f) => f.code.contains("'a")), false);

    // Lifetimes in these cases because of elideLifetimes true
    expect(
        functions.every((f) => (f..elideLifetimes = false).code.contains("'a")),
        true);

    // No lifeetimes in these cases because of elision
    expect(functions.any((f) => (f..elideLifetimes = true).code.contains("'a")),
        false);
  });

// end <main>
}
