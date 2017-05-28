library ebisu_rs.crate;

import 'package:ebisu/ebisu.dart';
import 'package:ebisu_rs/entity.dart';
import 'package:ebisu_rs/module.dart';
import 'package:id/id.dart';
import 'package:logging/logging.dart';

// custom <additional imports>
// end <additional imports>

final Logger _logger = new Logger('crate');

class Crate extends RsEntity {
  Module rootModule;

  // custom <class Crate>

  get children => [rootModule];

  toString() => brCompact(['Crate($id)', indentBlock(rootModule.toString())]);

  generate() {
    _logger.info('Generating crate $id');
    rootModule.generate();
  }

  // end <class Crate>

  Crate(id) : super(id);
}

// custom <library crate>

crate(id) => new Crate(id);

// end <library crate>
