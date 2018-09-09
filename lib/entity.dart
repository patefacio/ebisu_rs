/// Support for rust entity *recursive entity graph*.
///
/// All rust named items are *RsEntity* instances.
library ebisu_rs.entity;

import 'dart:io';
import 'dart:mirrors';
import 'package:ebisu/ebisu.dart';
import 'package:ebisu_rs/crate.dart';
import 'package:ebisu_rs/repo.dart';
import 'package:glob/glob.dart';
import 'package:id/id.dart';
import 'package:logging/logging.dart';

// custom <additional imports>

import 'package:ebisu_rs/module.dart';
import 'package:path/path.dart';

// end <additional imports>

final Logger _logger = new Logger('entity');

enum CrateType { libCrate, appCrate }

/// Convenient access to CrateType.libCrate with *libCrate* see [CrateType].
///
const CrateType libCrate = CrateType.libCrate;

/// Convenient access to CrateType.appCrate with *appCrate* see [CrateType].
///
const CrateType appCrate = CrateType.appCrate;

enum ModuleType {
  binaryModule,
  rootModule,
  inlineModule,
  fileModule,
  directoryModule
}

/// Convenient access to ModuleType.binaryModule with *binaryModule* see [ModuleType].
///
const ModuleType binaryModule = ModuleType.binaryModule;

/// Convenient access to ModuleType.rootModule with *rootModule* see [ModuleType].
///
const ModuleType rootModule = ModuleType.rootModule;

/// Convenient access to ModuleType.inlineModule with *inlineModule* see [ModuleType].
///
const ModuleType inlineModule = ModuleType.inlineModule;

/// Convenient access to ModuleType.fileModule with *fileModule* see [ModuleType].
///
const ModuleType fileModule = ModuleType.fileModule;

/// Convenient access to ModuleType.directoryModule with *directoryModule* see [ModuleType].
///
const ModuleType directoryModule = ModuleType.directoryModule;

/// Rust entity
abstract class RsEntity extends Object with Entity {
  /// Id for the [RsEntity]
  Id id;

  /// Indicates that general docComment should be suppressed
  bool noComment = false;

  // custom <class RsEntity>

  RsEntity(dynamic id) : this.id = makeRsId(id);

  @override
  Iterable<RsEntity> get children => new Iterable.empty();

  /// TODO: evaluate potential/need for this for better names of custom blocks
  String get dottedPathToModule {
    var current = this;
    final parts = [];
    do {
      parts.insert(0, current.id.snake);
      current = current.owner;
    } while (current != null && current is! Module);
    print('Finished current($current) => ${parts.join(".")}');
    return parts.join('.');
  }

  withThis(f(RsEntity t)) => f(this);

  /// Get the [rootPath] of this repo
  String get rootPath {
    RsEntity current = this;
    do {
      if (current is Repo) {
        return current.rootPath;
      }
      current = current.owner;
    } while (current != null);
    return '/tmp';
  }

  Crate get crate {
    RsEntity current = this;
    do {
      if (current is Crate) {
        return current;
      }
      current = current.owner;
    } while (current != null);
    return null;
  }

  RsEntity._copy(RsEntity other)
      : id = other.id,
        noComment = other.noComment;

  // end <class RsEntity>

}

abstract class HasFilePath {
  // custom <class HasFilePath>

  String get filePath;

  // end <class HasFilePath>

}

abstract class HasCode {
  // custom <class HasCode>

  String get code;

  // end <class HasCode>

}

/// Mixin for entities that support _pub_ keyword
abstract class IsPub {
  /// True indicates entity is public
  bool isPub = false;

  /// True indicates entity has pub(crate) visibility
  bool isPubCrate = false;

  // custom <class IsPub>

  String get pubDecl => isPub ? 'pub ' : isPubCrate ? 'pub(crate)' : '';

  // end <class IsPub>

}

abstract class HasCodeBlock {
  CodeBlock codeBlock;
}

class IsUnitTestable {
  bool isUnitTestable;
}

// custom <library entity>

makeRsId(dynamic id) => makeId(id is Symbol ? MirrorSystem.getName(id) : id);

RegExp _replaceable = new RegExp("[<> ,]");
RegExp _genericRe = new RegExp("<[^><]*>");

makeNonGenericId(String s) {
  var prior = s;

  do {
    prior = s;
    s = s.replaceAll(_genericRe, '');
  } while (s != prior);

  return makeId(s
      .replaceAll("'", '_')
      .replaceAll("::", '_')
      .replaceAll('&', 'ref_')
      .replaceAllMapped(new RegExp('([a-z])([A-Z])'),
          (Match m) => '${m[1]}_${m[2].toLowerCase()}')
      .toLowerCase());
}

makeGenericId(String s) => makeId(s
    .replaceAll(_replaceable, '')
    .replaceAll("'", '_')
    .replaceAll("::", '_')
    .replaceAll('&', 'ref_')
    .replaceAllMapped(new RegExp('([a-z])([A-Z])'),
        (Match m) => '${m[1]}_${m[2].toLowerCase()}')
    .toLowerCase());

String indent(String s) => indentBlock(s, '    ');

int formatRustFile(String filePath) {
  _logger.info("Running `rustfmt on $filePath");
  final fmtResult = Process.runSync('rustfmt', [filePath]);

  if (fmtResult.exitCode != 0) {
    print("WARNING: Format failed for: $filePath");
    print(fmtResult.stderr);
  }

  return fmtResult.exitCode;
}

/// Return a new string with [text] wrapped in `//!` doc comment block
String innerDocComment(String text, [String indent = ' ']) {
  String guts = text.trimRight().split('\n').join("\n//!$indent");
  return "//!$indent$guts";
}

// end <library entity>
