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
      ..typeParms = [#t]
      ..functions = [
        fn(#doWork, [parm(#unit, mref(i32)), parm(#t, 'T')]),
      ]..setAsRoot();

    var i1 = impl(t1, rsType('Vec<Vec<T>>'))
    //..typeParms = [#t]
    ..typeAliases.addAll([typeAlias(#assoc_1, i32), typeAlias(#assoc_2, i64)])
    ..setAsRoot();
    print(t1.code);
    print(i1.code);
  });

// end <main>
}
