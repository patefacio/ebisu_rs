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
  ModuleType get moduleType => _moduleType;
  List<Module> modules = [];
  List<Struct> structs = [];

  // custom <class Module>

  Module(id, [moduleType = fileModule])
      : super(id),
        _moduleType = moduleType;

  List<Module> get children => []..addAll(modules);

  toString() => 'mod($name:${isInline?"inline":"outline"})';

  onOwnershipEstablished() {
    final ownerPath = (owner as HasFilePath).filePath;

    _filePath = isDirectoryModule ? join(ownerPath, id.snake) : ownerPath;

    _logger.info("Ownership of module($id) established in $filePath");
  }

  generate() {
    _logger.info('Generating module $id:$filePath:$detailedPath');

    String targetPath = codePath;

    if (targetPath != null) mergeWithFile(code, targetPath);

    if (code.isNotEmpty) {
      print(code);
    }

    progeny.where((child) => (child as Module).isInline).forEach((module) {
      _logger.info('Found inline module ${module.entityPath}');
    });

    modules.forEach((module) => module.generate());
  }

  get codePath {
    if (isFileModule) {
      return join((owner as Module).filePath, '$name.rs');
    } else if (isDirectoryModule) {
      return join((owner as Module).filePath, name, 'mod.rs');
    } else if (isRootModule) {
      var crate = owner as Crate;
      return join(crate.filePath, crate.isLib ? 'lib.rs' : 'app.rs');
    }
    return null;
  }

  get isFileModule => moduleType == fileModule;
  get isDirectoryModule => moduleType == directoryModule;
  get isRootModule => moduleType == rootModule;

  get isInline => moduleType == inlineModule;

  get inlineMods => children.where((module) => module.isInline);

  get declaredMods => children.where((module) => !module.isInline);

  get name => id.snake;

  get code => brCompact([
        isInline ? 'mod $name {' : null,
        indentBlock(brCompact(declaredMods.map((module) => 'mod ${module.name};'))),
        indentBlock(br(structs.map((s) => s.code))),
        isInline ? '}' : null,
      ]);

  // end <class Module>

  String _filePath;
  ModuleType _moduleType;
}

// custom <library module>

module(id, [ModuleType moduleType = fileModule]) => new Module(id, moduleType);

// end <library module>
