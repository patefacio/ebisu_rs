library ebisu_rs.module;

import 'package:ebisu/ebisu.dart';
import 'package:ebisu_rs/crate.dart';
import 'package:ebisu_rs/entity.dart';
import 'package:ebisu_rs/struct.dart';
import 'package:id/id.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:quiver/iterables.dart';

// custom <additional imports>
// end <additional imports>

final Logger _logger = new Logger('module');

enum MainCodeBlock {
  /// The custom block appearing just after *main* is opened
  mainOpen,

  /// The custom block appearing just after *main* is closed
  mainClose
}

/// Convenient access to MainCodeBlock.mainOpen with *mainOpen* see [MainCodeBlock].
///
/// The custom block appearing just after *main* is opened
///
const MainCodeBlock mainOpen = MainCodeBlock.mainOpen;

/// Convenient access to MainCodeBlock.mainClose with *mainClose* see [MainCodeBlock].
///
/// The custom block appearing just after *main* is closed
///
const MainCodeBlock mainClose = MainCodeBlock.mainClose;

enum ModuleCodeBlock {
  /// The custom block appearing just after imports, mod statements and usings
  moduleTop,

  /// The custom block appearing at end of module
  moduleBottom
}

/// Convenient access to ModuleCodeBlock.moduleTop with *moduleTop* see [ModuleCodeBlock].
///
/// The custom block appearing just after imports, mod statements and usings
///
const ModuleCodeBlock moduleTop = ModuleCodeBlock.moduleTop;

/// Convenient access to ModuleCodeBlock.moduleBottom with *moduleBottom* see [ModuleCodeBlock].
///
/// The custom block appearing at end of module
///
const ModuleCodeBlock moduleBottom = ModuleCodeBlock.moduleBottom;

class Import {
  /// Name of crate to import
  String get import => _import;
  bool usesMacros = false;

  // custom <class Import>

  Import(this._import, [this.usesMacros = false]);

  get code => brCompact([
        usesMacros ? '#[macro_use]' : null,
        'extern crate $_import;',
      ]);

  // end <class Import>

  final String _import;
}

class Module extends RsEntity with IsPub implements HasFilePath, HasCode {
  String get filePath => _filePath;
  ModuleType get moduleType => _moduleType;
  List<Module> modules = [];
  List<Import> imports = [];
  List<Struct> structs = [];
  Map<ModuleCodeBlock, CodeBlock> moduleCodeBlocks = {};
  Map<MainCodeBlock, CodeBlock> mainCodeBlocks = {};

  // custom <class Module>

  Module(id, [moduleType = fileModule])
      : super(id),
        _moduleType = moduleType;

  Iterable<Module> get children => concat([structs, modules]);

  toString() => 'mod($name:$moduleType)';

  CodeBlock withCodeBlock(f(CodeBlock codeBlock)) =>
      f(_codeBlock ?? (_codeBlock = new CodeBlock('module $name')));

  CodeBlock withMainCodeBlock(MainCodeBlock mainCodeBlock, f(CodeBlock)) =>
      f(mainCodeBlocks.putIfAbsent(
          mainCodeBlock, () => codeBlock('main ${mainCodeBlock}')));

  onOwnershipEstablished() {
    var ownerPath = (owner as HasFilePath).filePath;

    if (owner is Crate) {
      ownerPath = join(ownerPath, 'src');
    }

    _filePath = isDirectoryModule || isInlineModule
        ? join(ownerPath, id.snake)
        : ownerPath;

    _logger.info("Ownership of module($id) established in $filePath");
  }

  import(import) => imports.add(import is Import ? import : new Import(import));

  importWithMacros(String crateName) =>
      imports.add(new Import(crateName, true));

  generate() {
    _logger
        .info('Generating module $pubDecl$id:$filePath:${chomp(detailedPath)}');

    if (isDeclaredModule) {
      mergeWithFile(code, codePath);
      formatRustFile(codePath);
    }

    modules.forEach((module) => module.generate());
  }

  get codePath {
    if (isFileModule) {
      return join(filePath, '$name.rs');
    } else if (isDirectoryModule) {
      return join(filePath, 'mod.rs');
    } else if (isRootModule) {
      var crate = owner as Crate;
      return join(filePath, crate.isLib ? 'lib.rs' : 'main.rs');
    } else {
      return join(filePath, name);
    }
  }

  get _inlineCode {
    if (isDeclaredModule) {
      addInlineCode(Iterable<Module> modules, List<String> guts) {
        for (Module module in modules) {
          _logger.info('!!!Examining ${module}');
          if (module.isInlineModule) {
            guts.add('${module.pubDecl}mod ${module.name} {');
            guts.add(module.code);
            addInlineCode(module.modules, guts);
            guts.add('}');
          }
        }
      }

      List<String> guts = [];
      addInlineCode(modules, guts);

      if (_codeBlock != null) {
        guts.add(_codeBlock.toString());
      }
      return brCompact(guts);
    }
  }

  get isFileModule => moduleType == fileModule;
  get isDirectoryModule => moduleType == directoryModule;
  get isRootModule => moduleType == rootModule;
  get isInlineModule => moduleType == inlineModule;
  get isDeclaredModule => moduleType != inlineModule;

  get inlineMods => modules.where((module) => module.isInlineModule);

  get declaredMods => modules.where((module) => module.isDeclaredModule);

  get name => id.snake;

  get _structDecls => br(structs.map((s) => s.code));

  get _imports => brCompact(imports.map((i) => i.code));

  get code => brCompact([
        _imports,
        brCompact(declaredMods
            .map((module) => '${module.pubDecl}mod ${module.name};')),
        isDeclaredModule ? _structDecls : indent(_structDecls),
        _inlineCode,
        _main,
      ]);

  get _hasMain => mainCodeBlocks.isNotEmpty;

  _mainCodeBlockText(MainCodeBlock mainCodeBlock) =>
      mainCodeBlocks[mainCodeBlock]?.toString();

  get _main => _hasMain
      ? brCompact([
      'fn main() {',
      _mainCodeBlockText(mainOpen),
      _mainCodeBlockText(mainClose),
      '}'
      ]) : null;

  // end <class Module>

  String _filePath;
  ModuleType _moduleType;
  CodeBlock _codeBlock;
}

// custom <library module>

module(id, [ModuleType moduleType = fileModule]) => new Module(id, moduleType);

// end <library module>
