library ebisu_rs.test_module;

import 'package:ebisu_rs/module.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>
import 'package:ebisu/ebisu.dart';
// end <additional imports>

final Logger _logger = new Logger('test_module');

// custom <library test_module>

// end <library test_module>

void main([List<String> args]) {
  if (args?.isEmpty ?? false) {
    Logger.root.onRecord.listen(
        (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
    Logger.root.level = Level.OFF;
  }
// custom <main>

  test('create module uses clippy', () {
    var r = repo('r')
      ..crates = [
        crate('c')
          ..rootModule = (module('sub_mod_2')
            ..functions = [
              fn(#do_work, [parm(#unit, i32)])
            ]
            ..uses = ['someType', pubUse('pubUseType')]
            ..addUses(['foo::goo'])
            ..addPubUses(['for_consumption::foo'])
            ..addUseForTest('useForTest')
            ..addUsesForTest(['a', use('b')])
            ..useClippy = true)
      ]
      ..setAsRoot();

    final subMod2 = r.crates.first.modules
        .firstWhere((Module m) => m.id.snake == 'sub_mod_2');

    expect(
        subMod2.code
            .contains('#![cfg_attr(feature="clippy", feature(plugin))]'),
        true);
    expect(subMod2.code.contains('\nuse someType;'), true);
    expect(subMod2.code.contains('\nuse foo::goo;'), true);
    expect(subMod2.code.contains('\npub use pubUseType;'), true);
    expect(subMod2.code.contains('\npub use for_consumption::foo;'), true);

    expect(
        subMod2.code.contains(
            new RegExp(r'mod tests {[^}]*use useForTest;', multiLine: true)),
        true);
    expect(
        subMod2.code
            .contains(new RegExp(r'mod tests {[^}]*use b;', multiLine: true)),
        true);
    expect(
        subMod2.code
            .contains(new RegExp(r'mod tests {[^}]*use a;', multiLine: true)),
        true);

    expect(
        subMod2.code.contains('#![cfg_attr(feature="clippy", plugin(clippy))]'),
        true);

    expect(darkMatter(subMod2.code).contains(darkMatter('''
fn do_work(unit : i32) -> () {
  // custom <fn do_work>
  // end <fn do_work>
}
    ''')), true);
  });

// end <main>
}
