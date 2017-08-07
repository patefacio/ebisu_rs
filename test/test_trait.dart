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
    var f1 = fn('foo');
    print(f1.code);
    f1..returns = i32;

    print(f1.code);
  });

// end <main>
}
