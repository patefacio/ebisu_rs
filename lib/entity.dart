library ebisu_rs.entity;

import 'package:ebisu/ebisu.dart';
import 'package:id/id.dart';
import 'package:path/path.dart';

// custom <additional imports>
// end <additional imports>

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

// custom <library entity>
// end <library entity>
