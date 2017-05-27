import 'package:logging/logging.dart';
import 'test_struct.dart' as test_struct;

main() {
  Logger.root.level = Level.OFF;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  test_struct.main();
}
