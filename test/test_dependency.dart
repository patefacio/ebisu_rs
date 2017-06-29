library ebisu_rs.test_dependency;

import 'package:ebisu_rs/dependency.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>
// end <additional imports>

final Logger _logger = new Logger('test_dependency');

// custom <library test_dependency>
// end <library test_dependency>

void main([List<String> args]) {
  if (args?.isEmpty ?? false) {
    Logger.root.onRecord.listen(
        (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
    Logger.root.level = Level.OFF;
  }
// custom <main>

  test('version spec parse', () {
    {
      final spec = new VersionSpec.fromString('> 1.1.1');
      expect(spec.toString(), '>1.1.1');
    }
    {
      final spec = new VersionSpec.fromString('>=1');
      expect(spec.toString(), '>=1');
    }
    {
      final spec = new VersionSpec.fromString('<= 1.3');
      expect(spec.toString(), '<=1.3');
    }
    {
      final spec = new VersionSpec.fromString('~ 1.3.2');
      expect(spec.toString(), '~1.3.2');
    }
    {
      final spec = new VersionSpec.fromString('>2.3.1,<=2.3.5,=2.3.2');
      expect(spec.toString(), '>2.3.1, <=2.3.5, =2.3.2');
    }
  });

// end <main>
}
