library ebisu_rs.test_impl;

import 'package:ebisu_rs/impl.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>

import 'package:ebisu/ebisu.dart';

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
    var worker = trait(#worker)
      ..attrs.add(idAttr(#bam))
      ..associatedTypes = ['assoc_1', 'assoc_2']
      ..typeParms = [#t]
      ..functions = [
        fn(#doWork, [parm(#unit, mref(i32)), parm(#t, 'T')])
          ..elideLifetimes = false
          ..doc = 'Does work of course',
      ]
      ..setAsRoot();

    Impl i1 = traitImpl(worker.inst(typeArgs: [#T]), rsType('Vec<Vec<T>>'))
      ..typeParms = [#t]
      ..typeAliases.addAll([typeAlias(#assoc_1, i32), typeAlias(#assoc_2, i64)])
      ..setAsRoot();

    expect(darkMatter(i1.code), darkMatter('''
/// TODO: comment impl worker_vec_vec_t
impl<T> Worker<T> for Vec<Vec<T>> {
  type Assoc1 = i32;
  type Assoc2 = i64;
  /// Does work of course
  ///
  ///  * `unit` - TODO: comment parm
  ///  * `t` - TODO: comment parm
  ///
  fn do_work<'a>(unit : & 'a mut i32, t : T) -> () {
    // custom <fn worker_vec_vec_t_do_work>
    // end <fn worker_vec_vec_t_do_work>
  }
  // custom <impl Worker for Vec<Vec<T>>>
  // end <impl Worker for Vec<Vec<T>>>
}
    '''));

    i1 = typeImpl(rsType('Foo'))
      ..functions = [
        fn(#doWork, [parm(#unit, mref(i32))])
          ..elideLifetimes = false
          ..doc = 'Does work of course',
      ]
      ..setAsRoot();

    expect(darkMatter(i1.code), darkMatter('''
    /// TODO: comment impl foo
impl Foo {
  /// Does work of course
  ///
  ///  * `unit` - TODO: comment parm
  ///
  fn do_work<'a>(unit : & 'a mut i32) -> () {
    // custom <fn foo_do_work>
    // end <fn foo_do_work>
  }
  // custom <impl Foo>
  // end <impl Foo>
}
    '''));
  });

// end <main>
}
