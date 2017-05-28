library ebisu_rs.module;

import 'package:ebisu/ebisu.dart';
import 'package:ebisu_rs/entity.dart';
import 'package:id/id.dart';
import 'package:logging/logging.dart';

// custom <additional imports>
// end <additional imports>

final Logger _logger = new Logger('module');

class Module extends RsEntity {
  List<Module> modules = [];

  // custom <class Module>

  get children => []..addAll(modules);

  toString() => brCompact(['Module($id)', indentBlock(brCompact(modules))]);

  generate() {
    _logger.info('Generating module $id');
    modules.forEach((module) => module.generate());
  }

  // end <class Module>

  Module(id) : super(id);
}

// custom <library module>

module(id) => new Module(id);

// end <library module>
