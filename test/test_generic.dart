library ebisu_rs.test_generic;

import 'package:ebisu_rs/generic.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>

import 'package:ebisu/ebisu.dart';
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
      ..fields = [
        field(#t1, #T1)..doc = 'The t1 factor',
        field(#t2, #T2)..doc = 'The t2 factor',
        field(#a, ref(#i64)),
        field(#b, ref(#i32, #b))
      ]
      // lifetimes inferred
      ..typeParms = [#t1, typeParm('t2')]
      ..setAsRoot();

    expect(s.genericDecl, "<'a, 'b, T1, T2>");
    expect(darkMatter(s.code), darkMatter('''
/// TODO: comment struct a
struct A<'a, 'b, T1, T2> {
  /// The t1 factor
  t1: T1,
  /// The t2 factor
  t2: T2,
  /// TODO: comment field
  a: & 'a i64,
  /// TODO: comment field
  b: & 'b i32,
}
    '''));
  });

  test('generic type', () {
    expect(lgt(#S, [#a, #b], gt(#T, [#i32])).code, "S<'a, 'b, T<i32>>");
    expect(gt(#Vec, #i32).code, 'Vec<i32>');
  });

// end <main>
}
