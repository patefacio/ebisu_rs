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
    Fn f1 = fn(#foobar, [
      parm(#a, mref(i32, 's'))..doc = 'The *i32* field called *a*',
      parm(#b, f64, true),
      parm(#c, string)
    ])
      ..elideLifetimes = false
      ..returns = ref(i32)
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
///  * _return_ - TODO: document return
///
#[bam]
fn foobar<'s, T1, T2>(a : & 's mut i32, mut b : f64, c : String) -> &'a i32;
    '''));

    f1.noComment = true;
    expect(f1.code.contains('Function that does foobar'), false);
    f1.noComment = false;

    f1..returns = i32;

    expect(darkMatter(f1.code), darkMatter('''
/// Function that does foobar
///
///  * `a` - The *i32* field called *a*
///  * `b` - TODO: comment parm
///  * `c` - TODO: comment parm
///  * _return_ - TODO: document return
///
#[bam]
fn foobar<'s, T1, T2>(a : & 's mut i32, mut b : f64, c : String) -> i32;
    '''));

    expect(pubFn(#foo).code.contains('pub fn foo'), true);
  });

  test('trait basics', () {
    var t1 = trait(#worker)
      ..attrs.add(idAttr(#bam))
      ..subTraits = ['Add', 'Mul', 'Div', 'Sized']
      ..associatedTypes = [
        'assoc_1',
        associatedType('assoc_2')..bounds = ['Foo', 'Goo']
      ]
      ..lifetimes = [#b]
      ..typeParms = [
        typeParm(#t)..bounds = ['Copy', 'std::fmt::Debug']
      ]
      ..functions = [
        fn(#doWork, [parm(#unit, mref(i32))])..doc = 'Does work of course',
      ]
      ..setAsRoot();

    _logger.info(t1.code);

    expect(darkMatter(t1.code), darkMatter('''
/// TODO: comment trait Worker
#[bam]
trait Worker<'b, T>: Add + Mul + Div + Sized where T : Copy + std::fmt::Debug {
  /// TODO: comment associated type assoc_1
  type Assoc1;
  /// TODO: comment associated type assoc_2
  type Assoc2: Foo + Goo;
  /// Does work of course
  ///
  ///  * `unit` - TODO: comment parm
  ///
  fn do_work(unit : & mut i32) -> ();
  // custom <trait_worker>
  // end <trait_worker>
} 
    '''));
  });

  test('trait self', () {
    var t1 = trait(#worker)
      ..functions = [
        fn(#doWorkSelf, [self, parm(#unit, i32)]),
        fn(#doWorkSelfRef, [selfRef, parm(#unit, i32)]),
        fn(#doWorkSelfRefMutable, [selfRefMutable, parm(#unit, i32)]),
      ]
      ..setAsRoot();

    final t1Code = darkMatter(t1.code);
    [
      "fn do_work_self(self, unit : i32) -> ();",
      "fn do_work_self_ref(& self, unit : i32) -> ();",
      "fn do_work_self_ref_mutable(& mut self, unit : i32) -> ();"
    ].forEach((sig) => expect(t1Code.contains(darkMatter(sig)), true));

    t1.functions.last.elideLifetimes = true;
    expect(
        darkMatter(t1.functions.last.code).contains(darkMatter(
            'fn do_work_self_ref_mutable(& mut self, unit : i32) -> ();')),
        true);
  });

  test('fn bounds', () {
    Fn f1 = fn(#foo)
      ..typeParms = [
        typeParm(#t)..bounds = ['Debug']
      ];
    expect(darkMatter(f1.code).contains(darkMatter('''
fn foo<T>() -> () where T : Debug;
    ''')), true);
  });

// end <main>
}
