library ebisu_rs.test_module;

import 'package:ebisu_rs/module.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>
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
            ..uses = ['someType']
            ..useClippy = true)
      ]
      ..setAsRoot();

    final subMod2 = r.crates.first.modules
        .firstWhere((Module m) => m.id.snake == 'sub_mod_2');

    expect(
        subMod2.code
            .contains('#![cfg_attr(feature="clippy", feature(plugin))]'),
        true);
    expect(subMod2.code.contains('use someType;'), true);
    expect(
        subMod2.code.contains('#![cfg_attr(feature="clippy", plugin(clippy))]'),
        true);
  });

// end <main>
}
