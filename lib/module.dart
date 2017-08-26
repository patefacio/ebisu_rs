library ebisu_rs.module;

import 'dart:io';
import 'package:ebisu/ebisu.dart';
import 'package:ebisu_rs/attribute.dart';
import 'package:ebisu_rs/crate.dart';
import 'package:ebisu_rs/entity.dart';
import 'package:ebisu_rs/impl.dart';
import 'package:ebisu_rs/struct.dart';
import 'package:ebisu_rs/trait.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:quiver/iterables.dart';

export 'dart:io';
export 'package:ebisu_rs/attribute.dart';
export 'package:ebisu_rs/crate.dart';
export 'package:ebisu_rs/impl.dart';
export 'package:ebisu_rs/struct.dart';
export 'package:ebisu_rs/trait.dart';
export 'package:path/path.dart';
export 'package:quiver/iterables.dart';

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

  String get code => brCompact([
        usesMacros ? '#[macro_use]' : null,
        'extern crate $_import;',
      ]);

  // end <class Import>

  final String _import;
}

class Module extends RsEntity
    with IsPub, HasAttributes, HasTypeAliases
    implements HasFilePath, HasCode {
  String get filePath => _filePath;
  ModuleType moduleType;
  List<Module> modules = [];
  List<Import> imports = [];
  List<Enum> enums = [];
  List<Struct> structs = [];
  List<Trait> traits = [];
  List<Impl> impls = [];
  Map<ModuleCodeBlock, CodeBlock> get moduleCodeBlocks => _moduleCodeBlocks;
  Map<MainCodeBlock, CodeBlock> get mainCodeBlocks => _mainCodeBlocks;

  /// Include *clippy* support
  bool useClippy = false;

  // custom <class Module>

  Module(dynamic id, [this.moduleType]) : super(id);

  @override
  Iterable<Entity> get children =>
      concat(<List<Entity>>[enums, structs, modules]) as Iterable<Entity>;

  String toString() => 'mod($name:$moduleType)';

  void withMainCodeBlock(
          MainCodeBlock mainCodeBlock, void f(CodeBlock codeBlock)) =>
      f(mainCodeBlocks.putIfAbsent(
          mainCodeBlock, () => codeBlock('main ${mainCodeBlock}')));

  void withModuleCodeBlock(
          ModuleCodeBlock moduleCodeBlock, void f(CodeBlock codeBlock)) =>
      f(moduleCodeBlocks.putIfAbsent(
          moduleCodeBlock, () => codeBlock('main ${moduleCodeBlock}')));

  onOwnershipEstablished() {
    var ownerPath = (owner as HasFilePath).filePath;

    if (owner is Crate) {
      ownerPath = join(ownerPath, 'src');
    }

    if (useClippy) {
      attrs.addAll([
        strAttr('cfg_attr(feature="clippy", feature(plugin))'),
        strAttr('cfg_attr(feature="clippy", plugin(clippy))')
      ]);
    }

    _filePath = (isDirectoryModule || isInlineModule)
        ? join(ownerPath, id.snake)
        : ownerPath;

    _logger.info("Ownership of module($id) established in   $filePath");
  }

  void import(dynamic import) => import is Iterable
      ? import.forEach((dynamic i) => this.import(i))
      : imports.add(import is Import ? import : new Import(import as String));

  void importWithMacros(String crateName) =>
      imports.add(new Import(crateName, true));

  void generate() {
    _logger.info(
        'Generating module $pubDecl$id:$filePath:${chomp(detailedPath.toString())}');

    if (isDeclaredModule) {
      final tempFile = new File('${codePath}.ebisu_rs.rs');
      new Directory(tempFile.parent.path).createSync(recursive: true);
      tempFile.writeAsStringSync(code);
      formatRustFile(tempFile.path);
      final formattedCode = tempFile.readAsStringSync();
      mergeWithFile(formattedCode, codePath);
      tempFile.delete();
    }

    modules.forEach((module) => module.generate());
  }

  String get codePath {
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

  String get _inlineCode {
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

      return brCompact(guts);
    }
    return '';
  }

  bool get isFileModule => moduleType == fileModule;
  bool get isDirectoryModule => moduleType == directoryModule;
  bool get isRootModule => moduleType == rootModule;
  bool get isInlineModule => moduleType == inlineModule;
  bool get isDeclaredModule => moduleType != inlineModule;

  Iterable<Module> get inlineMods =>
      modules.where((module) => module.isInlineModule);

  Iterable<Module> get declaredMods =>
      modules.where((module) => module.isDeclaredModule);

  String get name => id.snake;
  String get _enumDecls => br(enums.map((e) => e.code));
  String get _structDecls => br(structs.map((s) => s.code));
  String get _traitDecls => br(traits.map((t) => t.code));
  String get _implDecls => br(impls.map((i) => i.code));
  String get _imports => brCompact(imports.map((i) => i.code));

  String get code => brCompact([
        tripleSlashComment(doc == null ? 'TODO: comment module $id' : doc),
        internalAttrs,
        _imports,
        brCompact(declaredMods
            .map((module) => '${module.pubDecl}mod ${module.name};')),
        typeAliasDecls,
        isDeclaredModule ? _enumDecls : indent(_enumDecls),
        isDeclaredModule ? _structDecls : indent(_structDecls),
        isDeclaredModule ? _traitDecls : indent(_traitDecls),
        isDeclaredModule ? _implDecls : indent(_implDecls),
        _inlineCode,
        _main,
      ]);

  bool get _hasMain => mainCodeBlocks.isNotEmpty;

  String _mainCodeBlockText(MainCodeBlock mainCodeBlock) =>
      mainCodeBlocks[mainCodeBlock]?.toString();

  String get _main => _hasMain
      ? brCompact([
          'fn main() {',
          _mainCodeBlockText(mainOpen),
          _mainCodeBlockText(mainClose),
          '}'
        ])
      : null;

  // end <class Module>

  String _filePath;
  Map<ModuleCodeBlock, CodeBlock> _moduleCodeBlocks = {};
  Map<MainCodeBlock, CodeBlock> _mainCodeBlocks = {};
}

// custom <library module>

Module module(dynamic id, [ModuleType moduleType = fileModule]) =>
    new Module(id, moduleType);

// end <library module>
