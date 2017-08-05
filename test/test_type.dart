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
    print(ref(mref(rsType('i32'), 'a'), 'a').lifetimeDecl);
    print(ref(mref(rsType('i32'), 'a'), 'b').code);
    //expect(rsType('i32'))
  });

// end <main>
}
