library ebisu_rs.module;

import 'dart:io';
import 'package:ebisu/ebisu.dart';
import 'package:ebisu_rs/attribute.dart';
import 'package:ebisu_rs/constant.dart';
import 'package:ebisu_rs/crate.dart';
import 'package:ebisu_rs/entity.dart';
import 'package:ebisu_rs/impl.dart';
import 'package:ebisu_rs/static.dart';
import 'package:ebisu_rs/struct.dart';
import 'package:ebisu_rs/trait.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:quiver/iterables.dart';

export 'dart:io';
export 'package:ebisu_rs/attribute.dart';
export 'package:ebisu_rs/constant.dart';
export 'package:ebisu_rs/crate.dart';
export 'package:ebisu_rs/impl.dart';
export 'package:ebisu_rs/static.dart';
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

class ModuleCodeBlock implements Comparable<ModuleCodeBlock> {
  /// The custom block appearing just after imports, mod statements and usings
  static const ModuleCodeBlock moduleTop = const ModuleCodeBlock._(0);

  /// The custom block appearing at end of module
  static const ModuleCodeBlock moduleBottom = const ModuleCodeBlock._(1);

  static List<ModuleCodeBlock> get values =>
      const <ModuleCodeBlock>[moduleTop, moduleBottom];

  final int value;

  int get hashCode => value;

  const ModuleCodeBlock._(this.value);

  ModuleCodeBlock copy() => this;

  int compareTo(ModuleCodeBlock other) => value.compareTo(other.value);

  String toString() {
    switch (this) {
      case moduleTop:
        return "ModuleTop";
      case moduleBottom:
        return "ModuleBottom";
    }
    return null;
  }

  static ModuleCodeBlock fromString(String s) {
    if (s == null) return null;
    switch (s) {
      case "ModuleTop":
        return moduleTop;
      case "ModuleBottom":
        return moduleBottom;
      default:
        return null;
    }
  }
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

class Import extends Object with HasAttributes {
  /// Name of crate to import
  String get import => _import;
  bool usesMacros = false;

  // custom <class Import>

  Import(this._import, [this.usesMacros = false]);

  String get code => brCompact([
        externalAttrs,
        usesMacros ? '#[macro_use]' : null,
        'extern crate $_import;',
      ]);

  // end <class Import>

  final String _import;
}

/// Represents a rust using statement
class Use extends Object with HasAttributes, IsPub implements Comparable<Use> {
  int compareTo(Use other) => used.compareTo(other.used);

  /// The symbol used
  String used;

  // custom <class Use>

  Use(this.used);

  String get useStatement => brCompact([externalAttrs, '${pubDecl}use $used;']);

  // end <class Use>

}

/// Provides for specific type of logging
abstract class LogProvider {
  // custom <class LogProvider>

  addModuleSupport(Module module);

  addCrateRequirements(Crate crate);

  // end <class LogProvider>

}

/// Provides for env_logger
class EnvLogProvider implements LogProvider {
  // custom <class EnvLogProvider>

  addCrateRequirements(Crate crate) => crate
    ..withCrateToml((toml) => toml
      ..addIfMissing(baseLogDependency)
      ..addIfMissing(new Dependency('env_logger', '^0.4.3')));

  addModuleSupport(Module module) {
    if (module.moduleType == binaryModule) {
      module.withMainCodeBlock(
          mainOpen,
          (CodeBlock cb) => cb.snippets.add(
              'env_logger::init().expect("Successful init of env_logger");'));
    }
  }

  // end <class EnvLogProvider>

}

/// Provides for flexi logger
class FlexiLogProvider implements LogProvider {
  // custom <class FlexiLogProvider>

  addCrateRequirements(Crate crate) => crate
    ..rootModule.importWithMacros('log')
    ..rootModule.import('flexi_logger')
    ..withCrateToml((toml) => toml
      ..addIfMissing(baseLogDependency)
      ..addIfMissing(new Dependency('flexi_logger', '^0.6.8')));

  addModuleSupport(Module module) {
    if (module.moduleType == binaryModule) {
      final Binary binary = module.owner;
      final hasLogLevel = binary.hasLogLevel;
      module
        ..import('flexi_logger')
        ..withMainCodeBlock(mainOpen, (CodeBlock cb) => cb.snippets.add('''
flexi_logger::Logger::with_str(${hasLogLevel? "options.log_level" : '"info"'})
    .start()
    .unwrap_or_else(|e| panic!("Logger initialization failed with {}", e));
${hasLogLevel? 'info!("clap parsed options {:?}", options);': ""}
              '''));
      if (hasLogLevel) {
        module.importWithMacros('log');
      }
    }
  }

  // end <class FlexiLogProvider>

}

/// Provides for slog logger
class SlogLogProvider implements LogProvider {
  // custom <class SlogLogProvider>

  addCrateRequirements(Crate crate) => crate
    ..rootModule.importWithMacros('log')
    ..withCrateToml((toml) => toml
      ..addIfMissing(baseLogDependency)
      ..addIfMissing(new Dependency('sloggers', '^0.2.1'))
      ..addIfMissing(new Dependency('slog', '^2.0.12')));

  addModuleSupport(Module module) {
    if (module.moduleType == binaryModule) {
      module
        ..import('sloggers')
        ..importWithMacros('slog')
        ..withMainCodeBlock(mainOpen, (CodeBlock cb) => cb.snippets.add('''
use sloggers::{Build, set_stdlog_logger};
use sloggers::terminal::{TerminalLoggerBuilder, Destination};
use sloggers::types::Severity;

let mut builder = TerminalLoggerBuilder::new();
builder.level(Severity::Debug);
builder.destination(Destination::Stderr);

let logger = builder.build().unwrap();
info!(logger, "Hello World!");
set_stdlog_logger(logger).expect("Setting ${module.id} logger succeed");

          '''));
    }
  }

  // end <class SlogLogProvider>

}

class Module extends RsEntity
    with
        IsPub,
        HasConstants,
        HasStatics,
        HasAttributes,
        HasTypeAliases,
        IsUnitTestable
    implements HasFilePath, HasCode {
  String get filePath => _filePath;
  ModuleType moduleType;
  List<Module> modules = [];
  List<Import> get imports => _imports;
  List<Enum> enums = [];
  List<StructType> structs = [];
  List<Trait> traits = [];
  List<Impl> impls = [];
  List<Fn> functions = [];
  Map<ModuleCodeBlock, CodeBlock> get moduleCodeBlocks => _moduleCodeBlocks;
  Map<MainCodeBlock, CodeBlock> get mainCodeBlocks => _mainCodeBlocks;

  /// List of use symbols for module
  List<Use> get uses => _uses;
  LoggerType loggerType;

  /// If not supplied, initialized from loggerType if set
  LogProvider logProvider;

  // custom <class Module>

  Module(dynamic id, [this.moduleType]) : super(id);

  @override
  Iterable<RsEntity> get children => concat(<Iterable<Entity>>[
        enums,
        structs,
        modules,
        traits,
        impls,
        _unitTestModule != null ? [_unitTestModule] : new Iterable.empty()
      ]) as Iterable<Entity>;

  String toString() => 'mod($name:$moduleType)';

  set uses(Iterable<dynamic> uses) {
    this._uses..clear();
    addUses(uses);
  }

  addUse(dynamic u) => this._uses.add(use(u));

  addUses(Iterable uses) => uses.forEach((u) => addUse(u));

  addPubUses(Iterable uses) => this._uses.addAll(uses.map(pubUse));

  addUseForTest(dynamic u) => withUnitTestModule((m) => m.addUse(u));

  addUsesForTest(Iterable uses) => withUnitTestModule((m) => m.addUses(uses));

  void withMainCodeBlock(
          MainCodeBlock mainCodeBlock, void f(CodeBlock codeBlock)) =>
      f(mainCodeBlocks.putIfAbsent(
          mainCodeBlock, () => codeBlock('main $name ${mainCodeBlock}')));

  void withModuleCodeBlock(
          ModuleCodeBlock moduleCodeBlock, void f(CodeBlock codeBlock)) =>
      f(moduleCodeBlocks.putIfAbsent(
          moduleCodeBlock, () => codeBlock('module $name ${moduleCodeBlock}')));

  void withUnitTestModule(void f(Module module)) => f(unitTestModule);

  Module get unitTestModule =>
      _unitTestModule ??
      (_unitTestModule = makeUnitTestModule()
        ..doc = 'Test module for $name module');

  get unitTestableFunctions => functions.where((fn) => fn.isUnitTestable);

  addUnitTest(Id id, [codeBlockTag]) =>
      unitTestModule.functions.add(makeUnitTestFunction(id, codeBlockTag));

  @override
  onOwnershipEstablished() {
    _logger.info('Ownership established for module ${owner?.id}:$id');
    if (owner != null) {
      var ownerPath = (owner as HasFilePath).filePath;

      if (owner is Crate) {
        ownerPath = join(ownerPath, 'src');
      }

      _filePath = (isDirectoryModule || isInlineModule)
          ? join(ownerPath, id.snake)
          : ownerPath;
    }

    // add unit tests

    if (loggerType != null) {
      logProvider = loggerType == envLogger
          ? new EnvLogProvider()
          : loggerType == flexiLogger
              ? new FlexiLogProvider()
              : loggerType == slogLogger
                  ? new SlogLogProvider()
                  : throw 'Unrecognized default log provider $loggerType';

      logProvider.addModuleSupport(this);
      logProvider.addCrateRequirements(this.crate);
    }

    if (isUnitTestable) addUnitTest(new Id('module_${id.snake}'));

    unitTestableFunctions.forEach((fn) => addUnitTest(fn.id));

    _logger.info("Ownership of module($id) established in   $filePath");
  }

  @override
  onChildrenOwnershipEstablished() {
    // Note: ownership of function children dictates whether they require unit test module
    impls
        .where((impl) => impl.hasUnitTestModule)
        .forEach((impl) => unitTestModule.modules.add(impl.unitTestModule));

    if (isBinaryModule) {
      // ensure main code block provided for binaries
      withMainCodeBlock(mainOpen, (m) => null);
    }
  }

  set imports(Iterable<dynamic> imports) =>
      _imports = imports.map((i) => new Import(i)).toList();

  void import(dynamic import) => import is Iterable
      ? import.forEach((dynamic i) => this.import(i))
      : _addImportIfNotPreset(
          import is Import ? import : new Import(import as String));

  _addImportIfNotPreset(Import import) =>
      imports.any((i) => i.import == import.import)
          ? null
          : imports.add(import);

  void importWithMacros(String crateName) =>
      _addImportIfNotPreset(new Import(crateName, true));

  withStructImpl(dynamic id, augmentStruct(Struct struct),
      augmentImpl(Struct s, TypeImpl typeImpl)) {
    final _id = makeRsId(id);
    final s = struct(_id);
    structs.add(s);
    augmentStruct(s);
    impls.add(typeImpl(s.genericName));
    augmentImpl(s, impls.last);
}

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
    if (isFileModule || isBinaryModule) {
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

  String _inlineCode(Iterable<Module> modules) {
    if (isDeclaredModule) {
      addInlineCode(Iterable<Module> modules, List<String> guts) {
        for (Module module in modules.where((m) => m.isInlineModule)) {
          if (!module.noComment) {
            guts.add(tripleSlashComment(module.doc?.toString() ??
                'TODO: comment internal module ${module.id.snake}'));
          }
          guts.add(module.externalAttrs);
          guts.add('${module.pubDecl}mod ${module.name} {');
          guts.add(module.code);
          addInlineCode(module.modules, guts);
          guts.add('}');
        }
      }

      List<String> guts = [];
      addInlineCode(modules, guts);

      return brCompact(guts);
    }
    return '';
  }

  bool get isBinaryModule => moduleType == binaryModule;
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
  String get _importsDecls => brCompact(imports.map((i) => i.code));

  get _sortedNonPubUses => uses.where((u) => !u.isPub).toList()..sort();
  get _sortedPubUses => uses.where((u) => u.isPub).toList()..sort();

  _announce(section, [bool hasContents = true]) =>
      !isInlineModule && hasContents ? '// --- module $section ---\n\n' : null;

  String get code {
    final pubUses = _sortedPubUses;
    final nonPubUses = _sortedNonPubUses;

    return br([
      !noComment && !isInlineModule
          ? innerDocComment(doc == null ? 'TODO: comment module $id' : doc)
          : null,

      // If this is an inline module, external attrs will be used
      isInlineModule ? null : internalAttrs,

      // imports
      br([
        _announce('imports', imports.isNotEmpty),
        brCompact(_importsDecls),
      ]),

      moduleCodeBlocks[moduleTop],

      // pub use statements
      br([
        _announce('pub use statements', pubUses.isNotEmpty),
        brCompact(pubUses.map((i) => i.useStatement)),
      ]),

      // use statements
      br([
        _announce('use statements', nonPubUses.isNotEmpty),
        brCompact(nonPubUses.map((i) => i.useStatement)),
      ]),

      // declared mods
      brCompact(
          declaredMods.map((module) => '${module.pubDecl}mod ${module.name};')),

      // type aliases
      br([
        _announce('type aliases', hasTypeAliases),
        brCompact(typeAliasDecls),
      ]),

      // constants
      br([
        _announce('constants', hasConstants),
        brCompact(constantDecls),
      ]),

      // statics
      br([
        _announce('statics', hasStatics),
        brCompact(staticDecls),
      ]),

      // enums
      br([
        _announce('enum definitions', enums.isNotEmpty),
        isDeclaredModule ? _enumDecls : indent(_enumDecls),
      ]),

      // structs
      br([
        _announce('struct definitinos', structs.isNotEmpty),
        isDeclaredModule ? _structDecls : indent(_structDecls),
      ]),

      // traits
      br([
        _announce('trait definitions', traits.isNotEmpty),
        isDeclaredModule ? _traitDecls : indent(_traitDecls),
      ]),

      // impls
      br([
        _announce('impl definitions', impls.isNotEmpty),
        isDeclaredModule ? _implDecls : indent(_implDecls),
      ]),

      // functions
      br([
        _announce('function definitions', functions.isNotEmpty),
        isDeclaredModule
            ? functions.map((fn) => (fn..codeBlock).code)
            : indent(br(functions.map((fn) => (fn..codeBlock).code))),
      ]),

      // inline code
      _inlineCode(modules),

      moduleCodeBlocks[moduleBottom],

      _unitTestModule == null ? null : _inlineCode([_unitTestModule]),

      _main,
    ]);
  }

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
  List<Import> _imports = [];
  Map<ModuleCodeBlock, CodeBlock> _moduleCodeBlocks = {};
  Map<MainCodeBlock, CodeBlock> _mainCodeBlocks = {};
  List<Use> _uses = [];

  /// Module `tests` for unit testing this containing modules functionality
  Module _unitTestModule;
}

// custom <library module>

/// Create a [Module] specified by [id] which may be a Symbol, String or Id
/// and [moduleType]
///
Module module(dynamic id, [ModuleType moduleType = fileModule]) =>
    new Module(id, moduleType);

/// Create a _public_ [Module] specified by [id] which may be a Symbol, String
/// or Id and [moduleType]
///
Module pubModule(dynamic id, [ModuleType moduleType = fileModule]) =>
    new Module(id, moduleType)..isPub = true;

/// Creates a [Module] with standard characteristics of `use super::*` and `#[cfg(test)]`
///
Module makeUnitTestModule() => module('tests', inlineModule)
  ..uses = ['super::*']
  ..attrs = [strAttr('cfg(test)')];

/// Create an [Import] specified by [import] which may be a Symbol, String or Id
/// and [usesMcros] indicating to add `#[macro_use]`
///
Import import(dynamic import, [bool usesMacros = false]) =>
    new Import(import, usesMacros);

/// Create an [Used] specified by [used]
///
Use use(dynamic used) => used is Use ? used : new Use(used);

/// Create an _public_ [Used] specified by [used]
///
Use pubUse(dynamic used) =>
    ((used is Use ? use : new Use(used)) as Use)..isPub = true;

get baseLogDependency => new Dependency('log', '^0.3.8');

// end <library module>
