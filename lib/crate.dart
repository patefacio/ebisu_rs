library ebisu_rs.crate;

import 'package:ebisu/ebisu.dart';
import 'package:ebisu_rs/entity.dart';
import 'package:ebisu_rs/module.dart';
import 'package:ebisu_rs/repo.dart';
import 'package:id/id.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';

// custom <additional imports>
// end <additional imports>

final Logger _logger = new Logger('crate');

enum ArgType { argString, argDouble, argInt32, argInt64 }

/// Convenient access to ArgType.argString with *argString* see [ArgType].
///
const ArgType argString = ArgType.argString;

/// Convenient access to ArgType.argDouble with *argDouble* see [ArgType].
///
const ArgType argDouble = ArgType.argDouble;

/// Convenient access to ArgType.argInt32 with *argInt32* see [ArgType].
///
const ArgType argInt32 = ArgType.argInt32;

/// Convenient access to ArgType.argInt64 with *argInt64* see [ArgType].
///
const ArgType argInt64 = ArgType.argInt64;

/// *clap* arg
class Arg {
  Id get id => _id;

  /// Short version of argument
  String short;
  String help;
  bool isRequired = false;
  bool isMultiple = false;
  String defaultValue;
  ArgType argType = argString;

  // custom <class Arg>

  Arg(id) : _id = makeId(id);

  get code => brCompact([
    '.arg(Arg::with_name("${id.snake}")',
    indentBlock(brCompact([
      '.long("${id.emacs}")',
      short != null ? '.short("${short}")' : null,
      isRequired ? '.required(true)' : null,
    ])),
    ')'
  ]);

  // end <class Arg>

  Id _id;
}

/// Models command line args per *clap* crate
class Clap {
  Clap(this.crate);

  Crate crate;
  String version;
  String author;
  String about;
  List<Arg> args = [];

  // custom <class Clap>

  get code => brCompact([
    'let matches = App::new("${crate.name}")',
    args.map((Arg arg) => arg.code),
    ]);


  // end <class Clap>

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
      rootModule.withCodeBlock((CodeBlock cb) => 
      cb.snippets.add('''
fn main() {  
${indentBlock(_clap.code)}
} 
'''      ));
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

arg(id) => new Arg(id);

// end <library crate>
