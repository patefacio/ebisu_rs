library ebisu_rs.entity;

import 'package:ebisu/ebisu.dart';
import 'package:id/id.dart';

// custom <additional imports>
// end <additional imports>

/// Rust entity
abstract class RsEntity extends Object with Entity {
  /// Id for the [RsEntity]
  Id id;

  // custom <class RsEntity>

  RsEntity(id) :
    this.id = makeId(id);
  
  // end <class RsEntity>

}

// custom <library entity>
// end <library entity>
