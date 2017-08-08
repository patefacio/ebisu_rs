/// Support for rust entity *recursive entity graph*.
///
/// All rust named items are *RsEntity* instances.
library ebisu_rs.entity;

import 'dart:io';
import 'dart:mirrors';
import 'package:ebisu/ebisu.dart';
import 'package:glob/glob.dart';
import 'package:id/id.dart';
import 'package:logging/logging.dart';

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

  RsEntity(dynamic id) : this.id = makeRsId(id);

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

  String get pubDecl => isPub ? 'pub ' : '';

  // end <class IsPub>

}

// custom <library entity>

makeRsId(dynamic id) => makeId(id is Symbol ? MirrorSystem.getName(id) : id);

String indent(String s) => indentBlock(s, '    ');

ProcessResult formatRustFile(String filePath) {
  _logger.info('Formatting rust file ${filePath}');
  final result = Process.runSync('rustfmt', ['--skip-children', filePath]);
  var backup = new File('$filePath.bk');
  if (backup.existsSync()) {
    _logger.info('Deleting backup ${backup.path}');
    backup.deleteSync();
  }
  var backups = new Glob('${filePath}.*~');
  for (var backup in backups.listSync()) {
    _logger.info('Deleting backup ${backup.path}');
    backup.deleteSync();
  }

  return result;
}

// end <library entity>
