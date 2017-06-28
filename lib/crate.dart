library ebisu_rs.crate;

import 'package:ebisu/ebisu.dart';
import 'package:ebisu_rs/entity.dart';
import 'package:ebisu_rs/module.dart';
import 'package:ebisu_rs/repo.dart';
import 'package:ebisu_rs/struct.dart';
import 'package:ebisu_rs/type.dart';
import 'package:id/id.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';

// custom <additional imports>
// end <additional imports>

final Logger _logger = new Logger('crate');

enum ArgType {
  argBool,
  argString,
  argI8,
  argI16,
  argI32,
  argI64,
  argU8,
  argU16,
  argU32,
  argU64,
  argIsize,
  argUsize,
  argF32,
  argF64
}

/// Convenient access to ArgType.argBool with *argBool* see [ArgType].
///
const ArgType argBool = ArgType.argBool;

/// Convenient access to ArgType.argString with *argString* see [ArgType].
///
const ArgType argString = ArgType.argString;

/// Convenient access to ArgType.argI8 with *argI8* see [ArgType].
///
const ArgType argI8 = ArgType.argI8;

/// Convenient access to ArgType.argI16 with *argI16* see [ArgType].
///
const ArgType argI16 = ArgType.argI16;

/// Convenient access to ArgType.argI32 with *argI32* see [ArgType].
///
const ArgType argI32 = ArgType.argI32;

/// Convenient access to ArgType.argI64 with *argI64* see [ArgType].
///
const ArgType argI64 = ArgType.argI64;

/// Convenient access to ArgType.argU8 with *argU8* see [ArgType].
///
const ArgType argU8 = ArgType.argU8;

/// Convenient access to ArgType.argU16 with *argU16* see [ArgType].
///
const ArgType argU16 = ArgType.argU16;

/// Convenient access to ArgType.argU32 with *argU32* see [ArgType].
///
const ArgType argU32 = ArgType.argU32;

/// Convenient access to ArgType.argU64 with *argU64* see [ArgType].
///
const ArgType argU64 = ArgType.argU64;

/// Convenient access to ArgType.argIsize with *argIsize* see [ArgType].
///
const ArgType argIsize = ArgType.argIsize;

/// Convenient access to ArgType.argUsize with *argUsize* see [ArgType].
///
const ArgType argUsize = ArgType.argUsize;

/// Convenient access to ArgType.argF32 with *argF32* see [ArgType].
///
const ArgType argF32 = ArgType.argF32;

/// Convenient access to ArgType.argF64 with *argF64* see [ArgType].
///
const ArgType argF64 = ArgType.argF64;

/// *clap* arg
class Arg {
  Id get id => _id;

  /// Documentation for arg
  String doc;

  /// Short version of argument
  String short;
  String help;
  bool isRequired = false;
  bool isMultiple = false;

  /// Sets default value for arg
  String defaultValue;
  ArgType argType = argString;

  // custom <class Arg>

  Arg(id) : _id = makeId(id);

  toString() => "arg(${id.snake})";

  get code {
    assert(!(isMultiple && defaultValue != null),
        "Args can not be isMultiple and have defaultValue $this");

    return brCompact([
      '.arg(Arg::with_name("${id.snake}")',
      indent(brCompact([
        doc != null ? '.help("${doc}")' : null,
        '.long("${id.emacs}")',
        short != null ? '.short("${short}")' : null,
        isRequired ? '.required(true)' : null,
        isMultiple ? '.multiple(true)' : null,
        defaultValue != null ? '.default_value("$defaultValue")' : null,
        (defaultValue == null) && takesValue ? '.takes_value(true)' : null,
      ])),
      ')'
    ]);
  }

  get takesValue => defaultValue != null || argType != argBool;

  get type => isMultiple ? 'Vec<${_baseType.scopedDecl}>' : _baseType;

  static final Map<ArgType, RsType> _baseTypes = {
    argString: ref(str, 'a'),
    argI8: i8,
    argI16: i16,
    argI32: i32,
    argI64: i64,
    argU8: u8,
    argU16: u16,
    argU32: u32,
    argU64: u64,
    argIsize: isize,
    argUsize: usize,
    argF32: f32,
    argF64: f64
  };
  get _baseType => _baseTypes[argType] ?? string;

  // end <class Arg>

  Id _id;
}

/// Collection of arguments and common features to satisfy *main* and subcommands
class Command {
  Id get id => _id;

  /// Documentation for app to override default generated
  String doc;
  String version;
  String author;
  String about;
  List<Arg> args = [];

  // custom <class Command>

  Command(id) : _id = makeId(id);

  // end <class Command>

  Id _id;
}

/// Models command line args per *clap* crate
class Clap {
  Crate crate;

  /// Create struct to store args and pull from matches
  bool pullArgs = true;

  /// Documentation for app to override default generated
  String doc;
  List<Arg> args = [];
  Command get command => _command;
  List<Command> subCommands = [];

  // custom <class Clap>

  Clap(this.crate) : _command = new Command(crate.id);

  set version(String version) => command.version = version;
  set author(String author) => command.author = author;
  set about(String about) => command.about = about;

  get code => brCompact([
        'extern crate clap;',
        'use clap::{App, Arg};',
        'let matches = App::new("${crate.name}")',
        indent(brCompact([
          doc != null ? '.help("$doc")' : null,
          '${args.map((Arg arg) => arg.code).join("").trim()}',
        ])),
        '.get_matches();',
      ]);

  get defineStructs =>
      pullArgs ? _defineStruct('${crate.name}_options', args) : null;

  _defineStruct(id, List<Arg> args) {
    var structDecl = struct(id)
      ..derive = [Debug]
      ..members.addAll(args.map((arg) => member(arg.id)
        ..doc = arg.doc
        ..type = arg.type));

    var literal = brCompact([
      '${structDecl.name} {',
      indent(brCompact(args.map(_pullArg))),
      '}',
    ]);

    var ctor = brCompact([
      'fn from_matches(matches: &\'a clap::ArgMatches) -> ${structDecl.name}<\'a> {',
      indent(literal),
      '}',
    ]);

    return brCompact([
      structDecl.code,
      'impl<\'a> ${structDecl.name}<\'a> {',
      indent(ctor),
      '}'
    ]);
  }

  _expectParse(Arg arg) =>
      '.expect("failed to parse arg (${arg.id.emacs}) of type (${arg.argType})")';

  _expectUnwrap(Arg arg) =>
      '.expect("failed to unwrap <value_of(\\"${arg.id.snake}\\")>")';

  _pullNonStringArg(Arg arg) =>
      '${arg.id.snake}: matches.value_of("${arg.id.snake}")${_expectUnwrap(arg)}.parse()${_expectParse(arg)},';

  _pullStringArg(Arg arg) =>
      '${arg.id.snake}: matches.value_of("${arg.id.snake}")${_expectUnwrap(arg)},';

  _pullSingleArg(Arg arg) =>
      arg.argType == argString ? _pullStringArg(arg) : _pullNonStringArg(arg);

  _pullMultipleNonStringArg(Arg arg) => '''
  ${arg.id.snake}: match matches.values_of("${arg.id.snake}") {
      None => vec![],
      Some(v) => v.into_iter().map(|x| x.parse()${_expectParse(arg)}).collect()
  },
  ''';

  _pullMultipleStringArg(Arg arg) => '''
  ${arg.id.snake}: match matches.values_of("${arg.id.snake}") {
     None => vec![],
     Some(v) => v.into_iter().collect()
  },
  ''';

  _pullMultipleArg(Arg arg) => arg.argType == argString
      ? _pullMultipleStringArg(arg)
      : _pullMultipleNonStringArg(arg);

  _pullArg(Arg arg) =>
      arg.isMultiple ? _pullMultipleArg(arg) : _pullSingleArg(arg);

  // end <class Clap>

  Command _command;
}

class Dependency {
  Dependency(this.crate, this.version);

  String crate;
  String version;
  bool isBuildDependency = false;
  String path;

  // custom <class Dependency>

  get _decl =>
      path != null ? '{ version = "$version", path = "$path" }' : '"$version"';

  toString() => '${crate} = $_decl';

  // end <class Dependency>

}

/// Create Dependency without new, for more declarative construction
Dependency dependency(String crate, String version) =>
    new Dependency(crate, version);

class CrateToml {
  Crate crate;
  List<Dependency> deps = [];
  List<Dependency> buildDeps = [];
  List<String> authors = [];
  String version = '0.0.1';
  String license = 'MIT';
  String homepage;
  String description;
  String repository;
  String documentation;
  List<String> keywords = [];
  String readme;
  List<String> categories = [];

  // custom <class CrateToml>

  CrateToml(Crate crate) : crate = crate;

  void generate() {
    _logger.info('Generating crate toml $crate');

    var tomlPath = join(crate.filePath, 'Cargo.toml');

    mergeWithFile(contents, tomlPath);
  }

  get contents => brCompact([
        '[package]',
        // name
        'name = "${crate.id}"',
        // version
        'version = "$version"',
        // authors
        'authors = [${authors.join(",")}]',
        // description
        'description = ${tripleDoubleQuote(documentation?? "TBD")}',
        // repository
        repository != null ? 'repositoryX   = "$repository"' : null,
        // homepage
        homepage != null ? 'homepage = "$homepage"' : null,
        // keywords
        'keywords = [${keywords.map((kw) => "\"$kw\"").join(",")}]',
        // license
        license != null ? 'license = "$license"' : null,
        // readme
        readme != null ? 'readme = "$readme"' : null,

        '\n[dependencies]',
        deps.join("\n"),

        _buildDeps,
      ]);

  get _buildDeps => buildDeps.isEmpty
      ? null
      : '''\n\n[build-dependencies]
${buildDeps.join("\n")}
  ''';

  // end <class CrateToml>

}

class Crate extends RsEntity implements HasFilePath {
  CrateType crateType;
  Module rootModule;
  String get filePath => _filePath;

  /// For app crates a command line argument processor
  Clap get clap => _clap;

  // custom <class Crate>

  Crate(id, [crateType = libCrate])
      : super(id),
        crateType = crateType,
        rootModule = new Module(id, ModuleType.rootModule) {
    _crateToml = new CrateToml(this);
  }

  Module withRootModule(f(Module module)) => f(rootModule);
  CrateToml withCrateToml(f(CrateToml crateToml)) => f(_crateToml);
  Clap withClap(f(Clap clap)) => f(_clap ?? (_clap = new Clap(this)));

  get children => new List<Module>.filled(1, rootModule, growable: false);

  toString() => 'crate($name)';

  onOwnershipEstablished() {
    _filePath = join((owner as Repo).rootPath, id.snake);
    _logger.info("Ownership of crate($id) established");
  }

  generate() {
    _logger.info('Generating crate $id into $filePath');

    if (_clap != null) {
      rootModule.withCodeBlock((CodeBlock cb) => cb.snippets.add(brCompact([
            _clap.defineStructs,
            '''
fn main() {  
${indent(_clap.code)}
${customBlock('module main ${rootModule.name}')}
} 
'''
          ])));
    }

    rootModule..generate();
    _crateToml.generate();
  }

  get isLib => crateType == libCrate;

  get isApp => crateType == appCrate;

  get name => id.snake;

  // end <class Crate>

  String _filePath;
  CrateToml _crateToml;
  Clap _clap;
}

// custom <library crate>

crate(id, [CrateType crateType = libCrate]) => new Crate(id, crateType);

Arg arg(id) => new Arg(id);

// end <library crate>
