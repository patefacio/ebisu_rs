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

class Crate extends RsEntity implements HasFilePath {
  Module rootModule;
  String get filePath => _filePath;

  // custom <class Crate>

  get children => [rootModule];

  toString() => brCompact(['Crate($name)', indentBlock(rootModule.toString())]);

  onOwnershipEstablished() {
    _filePath = join((owner as Repo).rootPath, id.snake);
    _logger.info("Ownership of crate($id) established");
  }

  generate() {
    var cratePath = join((root as Repo).rootPath, id.snake);
    _logger.info('Generating crate $id into $cratePath');
    rootModule.generate();
  }

  get name => id.snake;

  // end <class Crate>

  Crate(id) : super(id);

  String _filePath;
}

// custom <library crate>

crate(id) => new Crate(id);

// end <library crate>
