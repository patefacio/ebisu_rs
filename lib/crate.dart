library ebisu_rs.crate;

import 'package:ebisu/ebisu.dart';
import 'package:ebisu_rs/binary.dart';
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

export 'package:ebisu_rs/binary.dart';
export 'package:ebisu_rs/dependency.dart';
export 'package:ebisu_rs/enumeration.dart';
export 'package:ebisu_rs/module.dart';
export 'package:ebisu_rs/repo.dart';
export 'package:ebisu_rs/struct.dart';
export 'package:ebisu_rs/type.dart';

// custom <additional imports>
// end <additional imports>

final Logger _logger = new Logger('crate');

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

  /// Block for additional crate toml declarations
  set codeBlock(CodeBlock codeBlock) => _codeBlock = codeBlock;

  // custom <class CrateToml>

  CrateToml(this.crate);

  void generate() {
    _logger.info('Generating crate toml $crate');

    var tomlPath = join(crate.filePath, 'Cargo.toml');
    scriptMergeWithFile(contents, tomlPath);
  }

  void addIfMissing(Dependency dependency) {
    if (!deps.any((d) => d.crate == dependency.crate)) {
      deps.add(dependency);
    }
  }

  void addDep(String crateName, dynamic version) =>
      deps.add(dependency(crateName, version));

  CodeBlock get codeBlock =>
      _codeBlock ?? (_codeBlock = new ScriptCodeBlock('additional'));

  withCodeBlock(f(CodeBlock codeBlock)) => f(codeBlock);

  _nlText(s) => s == null ? null : '\n$s';

  String get contents => brCompact(<String>[
        '[package]',
        // name
        'name = "${crate.id.snake}"',
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
        new ScriptCodeBlock('dependencies').toString(),

        _buildDeps,

        _nlText(_codeBlock?.toString()),
      ]);

  String get _buildDeps => buildDeps.isEmpty
      ? null
      : '''\n\n[build-dependencies]
${buildDeps.join("\n")}
  ''';

  // end <class CrateToml>

  CodeBlock _codeBlock;
}

class Crate extends RsEntity implements HasFilePath {
  CrateType crateType;
  Module get rootModule => _rootModule;
  String get filePath => _filePath;

  /// For app crates a command line argument processor
  Clap get clap => _clap;

  /// Additional binaries in the create - deposited in `.../src/bin`
  List<Binary> binaries = [];

  // custom <class Crate>

  Crate(dynamic id, [CrateType crateType = libCrate])
      : crateType = crateType,
        _rootModule = new Module(id, ModuleType.rootModule),
        super(id) {
    _crateToml = new CrateToml(this);
  }

  set rootModule(Module rootModule) =>
      _rootModule = rootModule..moduleType = ModuleType.rootModule;

  void withRootModule(void f(Module module)) => f(rootModule);
  void withCrateToml(void f(CrateToml crateToml)) => f(_crateToml);
  void withClap(void f(Clap clap)) => f(_clap ?? (_clap = new Clap(id)));

  get children => concat([
        [rootModule],
        binaries
      ]);

  get modules => progeny.where((dynamic m) => m is Module);
  get enums => progeny.where((dynamic e) => e is Enum);
  get structs => progeny.where((dynamic s) => s is Struct);

  String get toml => _crateToml.contents;

  String toString() => 'crate($name)';

  @override
  onOwnershipEstablished() {
    _logger.info("Ownership of crate($id) established");
    final rootPath = this.rootPath ?? '../tmp';
    _filePath = join(rootPath, id.snake);
    if (_clap != null) {
      addClapToModule(rootModule, _clap);
    }
  }

  @override
  onChildrenOwnershipEstablished() {
    _addInferredDependencies();
  }

  void _addInferredDependencies() {
    if (requiresClap) {
      _crateToml.addIfMissing(new Dependency('clap', '^2.26.2'));
    }
    if (requiresSerde) {
      _crateToml.addIfMissing(new Dependency('serde', '^1.0.11'));
    }
  }

  bool get requiresClap =>
      _clap != null || binaries.any((bin) => bin.requiresClap);

  bool get requiresSerde => concat([
        enums,
        structs,
        concat([
          binaries.map((bin) => bin.module.enums),
          binaries.map((bin) => bin.module.structs)
        ])
      ]).any((item) =>
          (item is Derives) &&
          item.derive.any((derivable) =>
              derivable == Serialize || derivable == Deserialize));

  void generate() {
    _logger.info('Generating crate $id into $filePath');
    rootModule.generate();
    _crateToml.generate();
    binaries.forEach((bin) => bin.generate());
  }

  bool get isLib => crateType == libCrate;

  bool get isApp => crateType == appCrate;

  String get name => id.snake;

  // end <class Crate>

  Module _rootModule;
  String _filePath;
  CrateToml _crateToml;
  Clap _clap;
}

// custom <library crate>

Crate crate(dynamic id, [CrateType crateType = libCrate]) =>
    new Crate(id, crateType);

// end <library crate>
