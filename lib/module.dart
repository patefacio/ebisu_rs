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

class Module extends RsEntity with IsPub implements HasFilePath, HasCode {
  String get filePath => _filePath;
  ModuleType get moduleType => _moduleType;
  List<Module> modules = [];
  List<Struct> structs = [];

  // custom <class Module>

  Module(id, [moduleType = fileModule])
      : super(id),
        _moduleType = moduleType;

  List<Module> get children => []..addAll(modules);

  toString() => 'mod($name:$moduleType)';

  onOwnershipEstablished() {
    final ownerPath = (owner as HasFilePath).filePath;

    _filePath = isDirectoryModule ? join(ownerPath, id.snake) : ownerPath;

    _logger.info("Ownership of module($id) established in $filePath");
  }

  generate() {
    _logger
        .info('Generating module $pubDecl$id:$filePath:${chomp(detailedPath)}');

    if (isDeclaredMod) {
      mergeWithFile(code, codePath);
    }

    modules.forEach((module) => module.generate());
  }

  get codePath {
    if (isFileModule) {
      return join((owner as Module).filePath, '$name.rs');
    } else if (isDirectoryModule) {
      return join((owner as Module).filePath, name, 'mod.rs');
    } else if (isRootModule) {
      var crate = owner as Crate;
      return join(crate.filePath, crate.isLib ? 'lib.rs' : 'main.rs');
    }
    return null;
  }

  get _inlineCode {
    addInlineCode(Iterable<Module> modules, List<String> guts) {
      for (Module module in modules) {
        _logger.info('!!!Examining ${module}');
        if (module.isInline) {
          guts.add('${module.pubDecl}mod ${module.name} {');
          guts.add(module.code);
          addInlineCode(module.modules, guts);
          guts.add('}');
        }
      }
    }

    List<String> guts = [];
    addInlineCode(modules, guts);
    _logger.info('Done with guts:\n${indentBlock(brCompact(guts))}');
    return brCompact(guts);
  }

  get isFileModule => moduleType == fileModule;
  get isDirectoryModule => moduleType == directoryModule;
  get isRootModule => moduleType == rootModule;
  get isInline => moduleType == inlineModule;
  get isDeclaredMod => moduleType != inlineModule;

  get inlineMods => children.where((module) => module.isInline);

  get declaredMods => children.where((module) => module.isDeclaredMod);

  get name => id.snake;

  get _structDecls => br(structs.map((s) => s.code));

  get code => brCompact([
        brCompact(declaredMods
            .map((module) => '${module.pubDecl}mod ${module.name};')),
        isDeclaredMod ? _structDecls : indentBlock(_structDecls),
        _inlineCode,
      ]);

  // end <class Module>

  String _filePath;
  ModuleType _moduleType;
}

// custom <library module>

module(id, [ModuleType moduleType = fileModule]) => new Module(id, moduleType);

// end <library module>
