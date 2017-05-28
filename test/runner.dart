import 'package:logging/logging.dart';
import 'test_struct.dart' as test_struct;
import 'test_repo.dart' as test_repo;
import 'test_crate.dart' as test_crate;
import 'test_module.dart' as test_module;
import 'test_ebisu_rs.dart' as test_ebisu_rs;

void main() {
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  test_struct.main(null);
  test_repo.main(null);
  test_crate.main(null);
  test_module.main(null);
  test_ebisu_rs.main(null);
}
