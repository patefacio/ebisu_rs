library ebisu_rs.test_generic;

import 'package:ebisu_rs/generic.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>

import 'package:ebisu_rs/struct.dart';
import 'package:ebisu_rs/type.dart';

// end <additional imports>

final Logger _logger = new Logger('test_generic');

// custom <library test_generic>
// end <library test_generic>

void main([List<String> args]) {
  if (args?.isEmpty ?? false) {
    Logger.root.onRecord.listen(
        (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
    Logger.root.level = Level.OFF;
  }
// custom <main>

  test('lifetime', () {
    expect(lifetime(#a).code, "'a");
    expect(typeParm(#t).code, 'T');

    var s = struct('a')
      ..fields = [field('x', i32)..doc = 'The x factor']
      ..generic(['a', 'b'], ['t1', typeParm('t2')])
      ..setAsRoot();

    expect(s.genericDecl, "<'a, 'b, T1, T2>");

    print(s.code);
  });

// end <main>
}
