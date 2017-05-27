library ebisu_rs.test_struct;

import 'package:ebisu_rs/struct.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>
// end <additional imports>

final _logger = new Logger('test_struct');

// custom <library test_struct>
// end <library test_struct>

main([List<String> args]) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
// custom <main>

  test('struct creation', () {
    var s = struct('bam');
    print(s);
  });

// end <main>
}
