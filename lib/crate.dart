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

  get _buildDeps => buildDeps.isEmpty ? null : '''\n\n[build-dependencies]
${buildDeps.join("\n")}
  ''';
  
  // end <class CrateToml>

}

class Crate extends RsEntity implements HasFilePath {
  CrateType crateType;
  Module rootModule;
  String get filePath => _filePath;

  // custom <class Crate>

  Crate(id, [crateType = libCrate])
      : super(id),
        crateType = crateType,
        rootModule = new Module(id, ModuleType.rootModule) {
    _crateToml = new CrateToml(this);
  }

  Module withRootModule(f(Module module)) => f(rootModule);
  CrateToml withCrateToml(f(CrateToml crateToml)) => f(_crateToml);

  get children => new List<Module>.filled(1, rootModule, growable: false);

  toString() => 'crate($name)';

  onOwnershipEstablished() {
    _filePath = join((owner as Repo).rootPath, id.snake);
    _logger.info("Ownership of crate($id) established");
  }

  generate() {
    _logger.info('Generating crate $id into $filePath');
    rootModule.generate();
    _crateToml.generate();
  }

  get isLib => crateType == libCrate;

  get isApp => crateType == appCrate;

  get name => id.snake;

  // end <class Crate>

  String _filePath;
  CrateToml _crateToml;
}

// custom <library crate>

crate(id, [CrateType crateType = libCrate]) => new Crate(id, crateType);

// end <library crate>
