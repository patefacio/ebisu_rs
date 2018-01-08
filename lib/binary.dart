library ebisu_rs.binary;

import 'package:ebisu/ebisu.dart';
import 'package:ebisu_rs/dependency.dart';
import 'package:ebisu_rs/entity.dart';
import 'package:ebisu_rs/enumeration.dart';
import 'package:ebisu_rs/module.dart';
import 'package:ebisu_rs/repo.dart';
import 'package:ebisu_rs/struct.dart';
import 'package:ebisu_rs/type.dart';
import 'package:id/id.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:quiver/iterables.dart';

// custom <additional imports>
// end <additional imports>

final Logger _logger = new Logger('binary');

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

enum LoggerType { envLogger, flexiLogger, slogLogger }

/// Convenient access to LoggerType.envLogger with *envLogger* see [LoggerType].
///
const LoggerType envLogger = LoggerType.envLogger;

/// Convenient access to LoggerType.flexiLogger with *flexiLogger* see [LoggerType].
///
const LoggerType flexiLogger = LoggerType.flexiLogger;

/// Convenient access to LoggerType.slogLogger with *slogLogger* see [LoggerType].
///
const LoggerType slogLogger = LoggerType.slogLogger;

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

  Arg(dynamic id) : _id = makeRsId(id);

  toString() => "arg(${id.snake})";

  String get code {
    assert(!(isMultiple && defaultValue != null),
        "Args can not be isMultiple and have defaultValue $this");

    return brCompact(<String>[
      '.arg(Arg::with_name("${id.snake}")',
      indent(brCompact([
        doc != null ? '.help("${doc}")' : null,
        '.long("${id.emacs}")',
        short != null ? '.short("${short}")' : null,
        isRequired ? '.required(true)' : null,
        isMultiple ? '.multiple(true)' : null,
        defaultValue != null ? '.default_value("$defaultValue")' : null,
        ((defaultValue == null) && takesValue) ? '.takes_value(true)' : null,
      ])),
      ')'
    ]);
  }

  bool get takesValue => defaultValue != null || argType != argBool;

  get type => isMultiple
      ? (new UnmodeledGenericType('Vec')..typeArgs = [ref('str')])
      : _baseType;

  static final Map<ArgType, RsType> _baseTypes = {
    argBool: bool_,
    argString: ref(str),
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

  RsType get _baseType => _baseTypes[argType] ?? string;

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

  Command(dynamic id) : _id = makeRsId(id);

  // end <class Command>

  Id _id;
}

/// Models command line args per *clap* crate
class Clap {
  /// Create struct to store args and pull from matches
  bool pullArgs = true;

  /// Documentation for app to override default generated
  String doc;
  List<Arg> args = [];
  Command get command => _command;
  List<Command> subCommands = [];

  // custom <class Clap>

  Clap(dynamic id) : _command = new Command(makeRsId(id));

  set version(String version) => command.version = version;
  set author(String author) => command.author = author;
  set about(String about) => command.about = about;

  get id => command.id;

  get optionsStructId => makeRsId('${id.snake}_options');

  String mainStub([bool usesRunFunction = false]) => brCompact([
        '''
    let app = make_clap_app();
    let matches = app.get_matches();
    let options = ${optionsStructId.capCamel}::from_matches(&matches);'''
      ]);

  String get preMain => brCompact([defineStructs, fnGetApp]);

  String get invokeMainRun => '''
    if let Err(ref err) = main_run(options) {
        print!("Failed: {}", err);
        println!("{:?}", err.backtrace());
        let mut fail: &::failure::Fail = err.cause();

        while let Some(cause) = fail.cause() {
            println!("\t{}", cause);
            if let Some(backtrace) = cause.backtrace() {
                println!("BT{:?}", backtrace);
            }
            fail = cause;
        }

        ::std::process::exit(1);
    }
    ''';

  String get fnGetApp => brCompact([
        """
/// Creates a clap::App object based on modeled arguments.
///
///  * _return_ - `clap::App` created from modeled arguments
///
fn make_clap_app<'a, 'b>() -> clap::App<'a, 'b> {""",
        indentBlock(brCompact([
          'App::new("${id.snake}")',
          indent(brCompact([
            doc != null ? '.help("$doc")' : null,
            '${args.map((Arg arg) => arg.code).join("").trim()}',
          ])),
        ])),
        '}'
      ]);

  String get defineStructs =>
      pullArgs ? _defineOptionsStruct(optionsStructId, args) : null;

  String _defineOptionsStruct(Id optionsId, List<Arg> args) {
    Struct structDecl = struct(optionsId)
      ..doc = 'Struct to capture options for `${id.snake}` options.'
      ..derive = <Derivable>[Debug]
      ..fields.addAll(args.map((arg) => field(arg.id)
        ..doc = arg.doc
        ..type = arg.type))
      ..inferLifetimes();

    final lifetime = structDecl.lifetimes.isEmpty ? '' : "'a";
    final bracketLifetime = structDecl.lifetimes.isEmpty ? '' : "<'a>";

    String literal = brCompact(<String>[
      '${structDecl.unqualifiedName} {',
      indent(brCompact(args.map(_pullArg))),
      '}',
    ]);

    String ctor = brCompact(<String>[
      '''

/// Creates options from matches found by clap.
///
///  * `matches` - Matches clap found in command line arguments.
///  * _return_ - `${structDecl.genericName}` created from matches
///
fn from_matches(matches: &$lifetime clap::ArgMatches) -> ${structDecl.genericName} {''',
      indent(literal),
      '}',
    ]);

    return brCompact(<String>[
      structDecl.code,
      'impl$bracketLifetime ${structDecl.genericName} {',
      indent(ctor),
      '}'
    ]);
  }

  String _expectParse(Arg arg) =>
      '.expect("failed to parse arg (${arg.id.emacs}) of type (${arg.argType})")';

  String _expectUnwrap(Arg arg) =>
      '.expect("failed to unwrap <value_of(\\"${arg.id.snake}\\")>")';

  String _pullNonStringArg(Arg arg) =>
      '${arg.id.snake}: matches.value_of("${arg.id.snake}")${_expectUnwrap(arg)}.parse()${_expectParse(arg)},';

  String _pullFlagArg(Arg arg) =>
      '${arg.id.snake}: match matches.occurrences_of("${arg.id.snake}") { 0 => false, _ => true },';

  String _pullStringArg(Arg arg) =>
      '${arg.id.snake}: matches.value_of("${arg.id.snake}")${_expectUnwrap(arg)},';

  String _pullSingleArg(Arg arg) =>
      arg.argType == argString ? _pullStringArg(arg) : _pullNonStringArg(arg);

  String _pullMultipleNonStringArg(Arg arg) => '''
  ${arg.id.snake}: match matches.values_of("${arg.id.snake}") {
      None => vec![],
      Some(v) => v.into_iter().map(|x| x.parse()${_expectParse(arg)}).collect()
  },
  ''';

  String _pullMultipleStringArg(Arg arg) => '''
  ${arg.id.snake}: match matches.values_of("${arg.id.snake}") {
     None => vec![],
     Some(v) => v.into_iter().collect()
  },
  ''';

  String _pullMultipleArg(Arg arg) => arg.argType == argString
      ? _pullMultipleStringArg(arg)
      : _pullMultipleNonStringArg(arg);

  String _pullArg(Arg arg) => arg.isMultiple
      ? _pullMultipleArg(arg)
      : arg.argType == argBool ? _pullFlagArg(arg) : _pullSingleArg(arg);

  // end <class Clap>

  Command _command;
}

/// An executable generated into the `src/bin/` path of the crate
class Binary extends RsEntity implements HasFilePath {
  /// If set includes _clap_ _Arg_ to set log level
  bool hasLogLevel = false;

  /// For command line options of the binary
  Clap get clap => _clap;

  /// Module for the binary
  Module get module => _module;

  /// If set binary uses *failure* crate and invokes `run` method
  bool usesRunFunction = false;

  // custom <class Binary>

  String get filePath => join(rootPath, owner.id.snake, 'src', 'bin');

  Binary(dynamic id)
      : _module = new Module(id, binaryModule),
        super(id);

  String get code => module.code;

  withModule(f(Module)) => f(module);

  withClap(f(clap)) => f(_clap ?? (_clap = new Clap(id)));

  bool get requiresClap => _clap != null;

  @override
  onOwnershipEstablished() {
    if (hasLogLevel) {
      withClap((Clap clap) => clap.args.add(arg('log_level')
        ..defaultValue = 'warn'
        ..doc = 'Set level {none, error, warn, info, debug, trace}'));
    }

    if (_clap != null) {
      addClapToModule(module, _clap, usesRunFunction);
    }
  }

  @override
  onChildrenOwnershipEstablished() {}

  generate() => module.generate();

  get children => [module];

  // end <class Binary>

  Clap _clap;
  Module _module;
}

// custom <library binary>

Arg arg(dynamic id) => new Arg(id);

Binary binary(dynamic id) => new Binary(id);

addClapToModule(Module module, Clap clap, [usesRunFunction = false]) {
  final List<String> preMain = [clap.preMain];

  if (usesRunFunction) {
    preMain.add((fn('main_run', [
      parm('options', clap.optionsStructId.capCamel)
        ..doc = 'Options parsed/pulled from command line'
    ])
          ..doc =
              'Bulk of main, placed in run function consistent error handling'
          ..returns = '::std::result::Result<(), ::failure::Error>'
          ..returnDoc = 'The Error'
          ..codeBlock.tag = 'main run'
          ..withCodeBlock((cb) => cb.snippets.add('Ok(())')))
        .code);
    module
      ..importWithMacros('failure')
      ..withMainCodeBlock(
          mainClose,
          (cb) => cb
            ..snippets.add(clap.invokeMainRun)
            ..tag = null);
  }

  return module
    ..import('clap')
    ..uses.addAll([use('clap::{App, Arg}')])
    ..withModuleCodeBlock(
        moduleBottom, (cb) => cb.snippets.add(brCompact(preMain)))
    ..withMainCodeBlock(
        mainOpen,
        (CodeBlock cb) => cb
          ..hasSnippetsFirst = true
          ..snippets.add(brCompact([
            indent(clap.mainStub(usesRunFunction)),
          ])));
}

main() => print('done');

// end <library binary>
