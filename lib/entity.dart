/// Support for rust entity *recursive entity graph*.
///
/// All rust named items are *RsEntity* instances.
library ebisu_rs.entity;

import 'dart:io';
import 'package:ebisu/ebisu.dart';
import 'package:id/id.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';

// custom <additional imports>
// end <additional imports>

final Logger _logger = new Logger('entity');

enum CrateType { libCrate, appCrate }

/// Convenient access to CrateType.libCrate with *libCrate* see [CrateType].
///
const CrateType libCrate = CrateType.libCrate;

/// Convenient access to CrateType.appCrate with *appCrate* see [CrateType].
///
const CrateType appCrate = CrateType.appCrate;

enum ModuleType { rootModule, inlineModule, fileModule, directoryModule }

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

  // custom <class RsEntity>

  RsEntity(id) : this.id = makeId(id);

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

class IsPub {
  bool isPub = false;

  // custom <class IsPub>

  get pubDecl => isPub ? 'pub ' : '';

  // end <class IsPub>

}

// custom <library entity>

indent(s) => indentBlock(s, '    ');

formatRustFile(filePath) =>
    Process.runSync('rustfmt', ['--skip-children', filePath]);
    
// end <library entity>
