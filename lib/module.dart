library ebisu_rs.module;

import 'dart:io';
import 'package:ebisu/ebisu.dart';
import 'package:ebisu_rs/attribute.dart';
import 'package:ebisu_rs/common_traits.dart';
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
  /// Section corresponding to attributes, including features, plugins etc, above `moduleType`
  static const ModuleCodeBlock moduleAttributes = const ModuleCodeBlock._(0);

  /// The custom block appearing just after imports, mod statements and usings
  static const ModuleCodeBlock moduleTop = const ModuleCodeBlock._(1);

  /// The custom block appearing at end of module
  static const ModuleCodeBlock moduleBottom = const ModuleCodeBlock._(2);

  static List<ModuleCodeBlock> get values =>
      const <ModuleCodeBlock>[moduleAttributes, moduleTop, moduleBottom];

  final int value;

  int get hashCode => value;

  const ModuleCodeBlock._(this.value);

  ModuleCodeBlock copy() => this;

  int compareTo(ModuleCodeBlock other) => value.compareTo(other.value);

  String toString() {
    switch (this) {
      case moduleAttributes:
        return "ModuleAttributes";
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
      case "ModuleAttributes":
        return moduleAttributes;
      case "ModuleTop":
        return moduleTop;
      case "ModuleBottom":
        return moduleBottom;
      default:
        return null;
    }
  }
}

/// Convenient access to ModuleCodeBlock.moduleAttributes with *moduleAttributes* see [ModuleCodeBlock].
///
/// Section corresponding to attributes, including features, plugins etc, above `moduleType`
///
const ModuleCodeBlock moduleAttributes = ModuleCodeBlock.moduleAttributes;

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

  static final _namedItems = new RegExp(r'(.*){([^}]+)}');

  Use(this.used) {
    final terms = _namedItems.firstMatch(used);
    if (terms != null) {
      final prefix = terms.group(1);
      final guts = terms.group(2);
      final terms_ = guts.split(new RegExp(r'\s*,\s*'));
      terms_.sort();
      used = '${prefix}{${terms_.join(", ")}}';
    }
  }

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

/// Model a lazy static variable
class LazyStatic extends RsEntity with IsPub implements HasCode {
  /// Type of global being initialized
  RsType type;

  /// Block for initialization
  CodeBlock codeBlock;

  // custom <class LazyStatic>

  LazyStatic(globalId, type)
      : type = rsType(type),
        super(globalId) {
    codeBlock = new CodeBlock(id.snake);
  }

  set initializer(init) {
    codeBlock.snippets.add(init);
    codeBlock.tag = null;
  }

  get code => brCompact([
        'lazy_static! {',
        indentBlock(brCompact([
          '${isPub? "pub ": ""}static ref ${id.shout}: ${type.lifetimeDecl} = {',
          codeBlock.toString(),
          '};'
        ])),
        '}'
      ]);

  @override
  onOwnershipEstablished() {
    final module = owner as Module;
    if (module == null || !module.isTestModule) {
      this.crate.rootModule.importWithMacros('lazy_static');
    }
  }

  // end <class LazyStatic>

}

class Module extends RsEntity
    with
        IsPub,
        HasConstants,
        HasStatics,
        HasAttributes,
        HasTypeAliases,
        IsUnitTestable,
        HasFunctions
    implements HasFilePath, HasCode {
  String get filePath => _filePath;
  ModuleType moduleType;
  List<Module> modules = [];
  List<Import> get imports => _imports;
  List<Enum> enums = [];
  List<StructType> structs = [];
  List<Trait> traits = [];
  List<Impl> impls = [];
  Map<ModuleCodeBlock, CodeBlock> get moduleCodeBlocks => _moduleCodeBlocks;
  Map<MainCodeBlock, CodeBlock> get mainCodeBlocks => _mainCodeBlocks;

  /// List of use symbols for module
  List<Use> get uses => _uses;

  /// Any globals initialized for the module
  List<LazyStatic> lazyStatics = [];
  LoggerType loggerType;

  /// If not supplied, initialized from loggerType if set
  LogProvider logProvider;

  /// If set will add `#[cfg(test)]` attribute
  bool isTestModule = false;

  // custom <class Module>

  Module(dynamic id, [this.moduleType]) : super(id);

  @override
  Iterable<RsEntity> get children => concat(<Iterable<Entity>>[
        enums,
        structs,
        modules,
        traits,
        impls,
        _unitTestModule != null ? [_unitTestModule] : new Iterable.empty(),
        lazyStatics
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

  CodeBlock moduleCodeBlock(ModuleCodeBlock moduleCodeBlock) =>
      moduleCodeBlocks.putIfAbsent(
          moduleCodeBlock, () => codeBlock('module $name ${moduleCodeBlock}'));

  void withModuleCodeBlock(
          ModuleCodeBlock moduleCodeBlock, void f(CodeBlock codeBlock)) =>
      f(this.moduleCodeBlock(moduleCodeBlock));

  void withUnitTestModule(void f(Module module)) => f(unitTestModule);

  Module get unitTestModule =>
      _unitTestModule ??
      (_unitTestModule = makeUnitTestModule()
        ..doc = 'Test module for $name module');

  get unitTestableFunctions => functions.where((fn) => fn.isUnitTestable);

  addUnitTest(Id id, [codeBlockTag]) =>
      unitTestModule.functions.add(makeUnitTestFunction(id, codeBlockTag));

  get isTestsModule => id.snake == 'tests' && owner is Crate;

  Impl matchingImpl(Object id) {
    id = makeId(id);
    return impls.firstWhere((Impl impl) => impl.id == id);
  }

  withMatchingImpl(Object id, f(Impl impl)) => f(matchingImpl(id));

  withMatchingImpls(Iterable<Object> id, f(Impl impl)) =>
      id.forEach((id) => withMatchingImpl(id, f));

  Struct matchingStruct(Object id) {
    id = makeId(id);
    return structs.firstWhere((StructType struct) => struct.id == id,
        orElse: () =>
            throw 'Could not find matching struct $id in ${structs.map((s) => s.id).join(", ")}');
  }

  withMatchingStruct(Object id, f(StructType s)) => f(matchingStruct(id));

  withMatchingStructs(Iterable<Object> id, f(Struct struct)) =>
      id.forEach((id) => withMatchingStruct(id, f));

  withMatchingStructImpl(Object id, f(StructType struct, Impl impl)) {
    id = makeId(id);
    StructType struct = matchingStruct(id);
    f(struct, struct.impl);
  }

  ////////////////////
  Enum matchingEnum(Object id) {
    id = makeId(id);
    return enums.firstWhere((Enum enum_) => enum_.id == id,
        orElse: () =>
            throw 'Could not find matching enum $id in ${enums.map((s) => s.id).join(", ")}');
  }

  withMatchingEnum(Object id, f(Enum s)) => f(matchingEnum(id));

  withMatchingEnums(Iterable<Object> id, f(Enum enum_)) =>
      id.forEach((id) => withMatchingEnum(id, f));

  withMatchingEnumImpl(Object id, f(Enum enum_, Impl impl)) {
    id = makeId(id);
    Enum enum_ = matchingEnum(id);
    Impl impl =
        impls.firstWhere((Impl impl) => impl.id == id, orElse: () => null);
    if (impl == null) {
      impl = new TypeImpl(rsType(id));
      impls.add(impl);
    }
    f(enum_, impl);
  }
  ////////////////////

  @override
  onOwnershipEstablished() {
    _logger.info('Ownership established for module ${owner?.id}:$id');
    if (owner != null) {
      var ownerPath = (owner as HasFilePath).filePath;

      if (owner is Crate) {
        if (id.snake != 'tests') {
          ownerPath = join(ownerPath, 'src');
        }
      }

      _filePath = (isDirectoryModule || isInlineModule)
          ? join(ownerPath, id.snake)
          : ownerPath;
    }

    structs
        .where((StructType s) => s is Struct)
        .forEach((StructType struct) => (struct as Struct).setAccessors());

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

    structs.where((s) => s is Struct && s.hasAccessors).forEach((StructType s) {
      withMatchingStructImpl(s.id, (StructType s, Impl impl) {
        var struct = s as Struct;
        impl..functions.addAll(struct.accessors);
      });
    });

    List<Impl> sortedImpls = [];
    structs.forEach((StructType struct) {
      if (struct.hasImpl) {
        if (impls.where((Impl impl) => impl.id == struct.id && impl is TypeImpl).isEmpty) {
          sortedImpls.add(struct.impl);
        } else {
          print('Conflicting impls for ${struct.id.snake} in ${impls.map((i) => i.id.snake).join(", ")}');
        }
      }
    });
    sortedImpls.sort((a, b) => a.id.compareTo(b.id));
    impls.addAll(sortedImpls);

    _logger.info("Ownership of module($id) established in $filePath");
  }

  @override
  onChildrenOwnershipEstablished() {
    // Note: ownership of function children dictates whether they require unit test module
    impls
        .where((impl) => impl.hasUnitTestModule)
        .forEach((impl) => unitTestModule.modules.add(impl.unitTestModule));

    enums.where((e) => e.hasDefault).forEach((e) {
      impls.add(e.defaultImpl);
    });

    enums.where((e) => e.hasSnakeConversions).forEach((e) =>
        withMatchingEnumImpl(
            e.id,
            (Enum e, Impl i) =>
                i.functions.addAll(e.snakeConversionFunctions)));

    enums.where((e) => e.hasShoutConversions).forEach((e) =>
        withMatchingEnumImpl(
            e.id,
            (Enum e, Impl i) =>
                i.functions.addAll(e.shoutConversionFunctions)));

    if (isBinaryModule) {
      // ensure main code block provided for binaries
      withMainCodeBlock(mainOpen, (m) => null);
    }
  }

  set imports(Iterable<dynamic> imports) =>
      _imports = imports.map((i) => new Import(i)).toList();

  void import(dynamic import) => import is Iterable
      ? import.forEach((dynamic i) => this.import(i))
      : _addImportIfNotPresent(
          import is Import ? import : new Import(import as String));

  _addImportIfNotPresent(Import import) =>
      imports.any((i) => i.import == import.import)
          ? null
          : imports.add(import);

  void importWithMacros(String crateName, {bool allowUnused = false}) {
    final i = new Import(crateName, true);
    if (allowUnused) {
      i.attrs.add(strAttr('allow(unused_imports)'));
    }
    _addImportIfNotPresent(i);
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

  addNewType(String type, Id newTypeId) {
    final newTypeStruct = new TupleStruct(newTypeId)
      ..fieldTypes = [mref(rsType(type))]
      ..doc = 'New type for $type';

    structs.add(newTypeStruct);

    impls.add(traitImpl(derefTrait, newTypeStruct.inst(lifetimes: ['a']))
      ..lifetimes = ['a']
      ..codeBlock.tag = null
      ..typeAliases = [typeAlias('Target', type)]
      ..withThis((RsEntity impl) =>
          (impl as TraitImpl).matchingFunction('deref')..body = '&self.0'));
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

  set declaredModules(Iterable<Object> declaredModules) => _declaredModules =
      declaredModules.map((dm) => dm is Id ? dm : makeId(dm));

  Iterable<Object> get declaredMods => _declaredModules.isNotEmpty
      ? _declaredModules
      : modules.where((module) => module.isDeclaredModule);

  String get name => id.snake;
  String get _enumDecls => br(enums.map((e) => e.code));
  String get _structDecls => br(structs.map((s) => s.code));
  String get _traitDecls => br(traits.map((t) => t.code));
  String get _implDecls => br(impls.map((i) => i.code));
  String get _importsDecls => brCompact((new List.from(imports)
        ..sort((Import a, Import b) => a.import.compareTo(b.import)))
      .map((i) => i.code));

  get _sortedNonPubUses => uses.where((u) => !u.isPub).toList()..sort();
  get _sortedPubUses => uses.where((u) => u.isPub).toList()..sort();

  _announce(section, [bool hasContents = true]) =>
      !isInlineModule && hasContents ? '// --- module $section ---\n\n' : null;

  _modDeclaration(Object module) => module is Module
      ? brCompact([
          module.isTestModule ? '#[cfg(test)]' : null,
          '${module.pubDecl}mod ${module.name};',
        ])
      : 'mod ${(module as Id).snake};';

  String get code {
    final pubUses = _sortedPubUses;
    final nonPubUses = _sortedNonPubUses;

    return br([
      moduleCodeBlocks[moduleAttributes],

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
      !isTestsModule
          ? brCompact(declaredMods.map(_modDeclaration).toList()..sort())
          : null,

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
        _announce('struct definitions', structs.isNotEmpty),
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

      // lazy statics
      br([lazyStatics.map((ls) => ls.code)]),

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

  StructType findStruct(id) {
    final _id = makeRsId(id);
    return structs.firstWhere((s) => s.id == _id);
  }

  // end <class Module>

  String _filePath;

  /// List of modules that this module declares - for testing only.
  ///
  /// In general module declarations are fully discovered by the recursive
  /// design pattern (ie modules contain modules and a lib crate will declare
  /// its modules). However, special consideration exists for _tests_ module
  /// which does not blanket import modules since each module that is just
  /// a _fileModule_ is treated as its own crate. So, if this is a `tests`
  /// module and module Ids are set, this will declare those modules.
  List<Id> _declaredModules = [];
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

/// Create a [LazyStatic] specified by [globalId] with type [type].
LazyStatic lazyStatic(globalId, type) => new LazyStatic(globalId, type);

get baseLogDependency => new Dependency('log', '^0.3.8');

// end <library module>
