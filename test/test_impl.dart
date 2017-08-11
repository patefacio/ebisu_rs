library ebisu_rs.test_impl;

import 'package:ebisu_rs/impl.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>
// end <additional imports>

final Logger _logger = new Logger('test_impl');

// custom <library test_impl>
// end <library test_impl>

void main([List<String> args]) {
  if (args?.isEmpty ?? false) {
    Logger.root.onRecord.listen(
        (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
    Logger.root.level = Level.OFF;
  }
// custom <main>

  test('impl', () {
    var t1 = trait(#woker)
      ..attrs.add(idAttr(#bam))
      ..associatedTypes = ['assoc_1', 'assoc_2']
      ..lifetimes = [#b]
      ..typeParms = [#t]
      ..functions = [
        fn(#doWork, [parm(#unit, mref(i32))]),
      ];

    var i1 = impl(t1, rsType('Vec<i32>'));
    print(i1.code);
  });

// end <main>
}
