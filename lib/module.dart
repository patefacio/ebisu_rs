library ebisu_rs.module;

import 'package:ebisu/ebisu.dart';
import 'package:ebisu_rs/entity.dart';
import 'package:ebisu_rs/struct.dart';
import 'package:id/id.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';

// custom <additional imports>
// end <additional imports>

final Logger _logger = new Logger('module');

class Module extends RsEntity implements HasFilePath, HasCode {
  String get filePath => _filePath;
  List<Module> modules = [];
  List<Struct> structs = [];
  bool isInline = false;

  // custom <class Module>

  get children => []..addAll(modules);

  toString() => brCompact([
        'Module($name:${isInline?"inline":"outline"})',
        indentBlock(brCompact(modules))
      ]);

  onOwnershipEstablished() {
    _filePath = join((owner as HasFilePath).filePath, id.snake);
    _logger.info("Ownership of module($id) established in $filePath");
  }

  generate() {
    _logger.info('Generating module $id:$filePath:$detailedPath');
    var code = brCompact(structs.map((s) => s.code));
    if (code.isNotEmpty) {
      print('Mod code\n$code');
    }
    modules.forEach((module) => module.generate());
  }

  get name => id.snake;

  get code => toString();

  // end <class Module>

  Module(id) : super(id);

  String _filePath;
}

// custom <library module>

module(id) => new Module(id);

// end <library module>
