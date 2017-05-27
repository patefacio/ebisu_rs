library ebisu_rs.crate;

import 'package:ebisu/ebisu.dart';
import 'package:ebisu_rs/entity.dart';
import 'package:ebisu_rs/module.dart';
import 'package:id/id.dart';

// custom <additional imports>
// end <additional imports>

class Crate extends RsEntity {
  Module rootModule;

  // custom <class Crate>

  // end <class Crate>

  Crate(id) : super(id);
}

// custom <library crate>

crate(id) => new Crate(id);

// end <library crate>
