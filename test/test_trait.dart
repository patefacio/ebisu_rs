library ebisu_rs.test_trait;

import 'package:ebisu_rs/trait.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>

import 'package:ebisu/ebisu.dart';

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
    var f1 = fn(#foobar, [
      parm(#a, mref(i32, 's'))..doc = 'The *i32* field called *a*',
      parm(#b, f64),
      parm(#c, string)
    ])
      ..attrs = [idAttr(#bam)]
      ..typeParms = [#T1, #T2]
      ..doc = 'Function that does foobar'
      ..setAsRoot();

    expect(darkMatter(f1.code), darkMatter('''
/// Function that does foobar
///
///  * `a` - The *i32* field called *a*
///  * `b` - TODO: comment parm
///  * `c` - TODO: comment parm
///
#[bam]
fn foobar<'s, T1, T2>(a : & 's mut i32, b : f64, c : String) -> () {
}    
    '''));

    f1..returns = i32;

    expect(darkMatter(f1.code), darkMatter('''
/// Function that does foobar
///
///  * `a` - The *i32* field called *a*
///  * `b` - TODO: comment parm
///  * `c` - TODO: comment parm
///
#[bam]
fn foobar<'s, T1, T2>(a : & 's mut i32, b : f64, c : String) -> i32 {
}    
    '''));
  });

  test('trait basics', () {
    var t1 = trait(#woker)
      ..attrs.add(idAttr(#bam))
      ..lifetimes = [#b]
      ..typeParms = [#t]
      ..functions = [
        fn(#doWork, [parm(#unit, mref(i32))]),
      ]
      ..setAsRoot();

    expect(darkMatter(t1.code), darkMatter('''
/// TODO: comment trait woker
#[bam]
trait Woker<'b, T> {
  /// TODO: comment fn doWork
  ///
  ///  * `unit` - TODO: comment parm
  ///
  fn do_work<'a>(unit : & 'a mut i32) -> () {
  }
}    
    '''));
  });

// end <main>
}
