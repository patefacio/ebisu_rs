library ebisu_rs.test_attribute;

import 'package:ebisu_rs/attribute.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>
// end <additional imports>

final Logger _logger = new Logger('test_attribute');

// custom <library test_attribute>
// end <library test_attribute>

void main([List<String> args]) {
  if (args?.isEmpty ?? false) {
    Logger.root.onRecord.listen(
        (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
    Logger.root.level = Level.OFF;
  }
// custom <main>

  test('identifier attribute', () {
    print(idAttr(#test).internalAttr);
    print(attr(#abc, 'one_two_three').externalAttr);
    print(and([idAttr(#linux), idAttr(#windows)]).externalAttr);
  });

// end <main>
}
