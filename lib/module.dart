library ebisu_rs.module;

import 'package:ebisu/ebisu.dart';
import 'package:ebisu_rs/crate.dart';
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

  toString() => 'mod($name:${isInline?"inline":"outline"})';

  onOwnershipEstablished() {
    bool ownerIsCrate = owner is Crate;
    final ownerPath = (owner as HasFilePath).filePath;

    _filePath = ownerIsCrate ? ownerPath : join(ownerPath, id.snake);
    _logger.info("Ownership of module($id) established in $filePath");
  }

  generate() {
    _logger.info('Generating module $id:$filePath:$detailedPath');

    if (code.isNotEmpty) {
      print(code);
    }

    progeny.where((child) => (child as Module).isInline).forEach((module) {
      _logger.info('Found inline module ${module.entityPath}');
    });

    modules.forEach((module) => module.generate());
  }

  get name => id.snake;

  get code => brCompact([
        isInline ? 'mod $name {' : null,
        indentBlock(br(structs.map((s) => s.code))),
        isInline ? '}' : null,
      ]);

  // end <class Module>

  Module(id) : super(id);

  String _filePath;
}

// custom <library module>

module(id) => new Module(id);

// end <library module>
