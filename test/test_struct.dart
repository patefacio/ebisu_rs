library ebisu_rs.test_struct;

import 'package:ebisu_rs/struct.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>
import 'package:ebisu/ebisu.dart';
// end <additional imports>

final Logger _logger = new Logger('test_struct');

// custom <library test_struct>

// end <library test_struct>

void main([List<String> args]) {
  if (args?.isEmpty ?? false) {
    Logger.root.onRecord.listen(
        (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
    Logger.root.level = Level.OFF;
  }
// custom <main>

  test('struct creation', () {
    var s = struct('bam')
      ..typeParms = [#T]
      ..doc = 'Bam struct'
      ..fields = [field('foo'), field('goo', ref(ref(rsType('Vec<T>'))))]
      ..setAsRoot();

    expect(darkMatter(s.code), darkMatter('''
    /// Bam struct
struct Bam<'a, T> {
  /// TODO: comment field
  foo: String,
  /// TODO: comment field
  goo: & 'a & 'a Vec<T>,
}
    '''));

    s = ustruct('bong')..doc = 'Bong struct';
    expect(darkMatter(s.code), darkMatter('''
/// Bong struct
struct Bong;
'''));

    print((tstruct('tong')..doc = 'Tong struct').code);
  });

// end <main>
}
