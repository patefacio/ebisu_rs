library ebisu_rs.test_binary;

import 'package:ebisu_rs/binary.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>

import 'package:ebisu_rs/crate.dart';
import 'package:ebisu_rs/struct.dart';
import 'package:ebisu_rs/module.dart';

// end <additional imports>

final Logger _logger = new Logger('test_binary');

// custom <library test_binary>
// end <library test_binary>

void main([List<String> args]) {
  if (args?.isEmpty ?? false) {
    Logger.root.onRecord.listen(
        (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
    Logger.root.level = Level.OFF;
  }
// custom <main>

  test('basic binary', () {
    final bin = binary('simple_reader')
      ..withModule((module) => module.structs = [struct('s')])
      ..withClap((clap) => clap.args = [
            //
            arg('foo_bar')
              ..short = 'f'
              ..doc = 'Must be fubared'
              ..argType = argString
              ..isRequired = true,
          ]);

    var c = crate('crate')
      ..binaries = [bin]
      ..setAsRoot();

    expect(c.filePath, '/tmp/crate');
    expect(bin.filePath, '/tmp/crate/src/bin');
  });

// end <main>
}
