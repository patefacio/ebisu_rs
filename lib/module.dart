library ebisu_rs.module;

import 'package:ebisu/ebisu.dart';
import 'package:ebisu_rs/entity.dart';
import 'package:id/id.dart';

// custom <additional imports>
// end <additional imports>

class Module extends RsEntity {
  List<Module> modules = [];

  // custom <class Module>

  // end <class Module>

  Module(id) : super(id);
}

// custom <library module>

module(id) => new Module(id);

// end <library module>
