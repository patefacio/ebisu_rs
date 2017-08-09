import 'package:logging/logging.dart';
import 'test_attribute.dart' as test_attribute;
import 'test_type.dart' as test_type;
import 'test_struct.dart' as test_struct;
import 'test_repo.dart' as test_repo;
import 'test_crate.dart' as test_crate;
import 'test_module.dart' as test_module;
import 'test_trait.dart' as test_trait;
import 'test_generic.dart' as test_generic;
import 'test_enumeration.dart' as test_enumeration;
import 'test_ebisu_rs.dart' as test_ebisu_rs;
import 'test_dependency.dart' as test_dependency;

void main() {
  Logger.root.level = Level.OFF;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  test_attribute.main(null);
  test_type.main(null);
  test_struct.main(null);
  test_repo.main(null);
  test_crate.main(null);
  test_module.main(null);
  test_trait.main(null);
  test_generic.main(null);
  test_enumeration.main(null);
  test_ebisu_rs.main(null);
  test_dependency.main(null);
}
