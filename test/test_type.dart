library ebisu_rs.test_type;

import 'package:ebisu_rs/type.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>
// end <additional imports>

final Logger _logger = new Logger('test_type');

// custom <library test_type>
// end <library test_type>

void main([List<String> args]) {
  if (args?.isEmpty ?? false) {
    Logger.root.onRecord.listen(
        (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
    Logger.root.level = Level.OFF;
  }
// custom <main>

  test('types', () {
    var t = ref(mref(f64));
    expect(t.lifetimeDecl, "& 'a & 'a mut f64");
    expect(t.code, "& & mut f64");

    t = mref(ref(mref(i32, 'x'), 'y'));
    expect(t.lifetimeDecl, "& 'a mut & 'y & 'x mut i32");
    expect(t.code, "& mut & & mut i32");

    print(t.lifetimes);

    //expect(rsType('i32'))
  });

// end <main>
}
