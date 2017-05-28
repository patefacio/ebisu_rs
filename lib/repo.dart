library ebisu_rs.repo;

import 'package:ebisu/ebisu.dart';
import 'package:ebisu_rs/crate.dart';
import 'package:ebisu_rs/entity.dart';
import 'package:id/id.dart';

// custom <additional imports>
// end <additional imports>

class Repo extends RsEntity {
  List<Crate> crates = [];

  // custom <class Repo>

  get children => []..addAll(crates);

  // end <class Repo>

  Repo(id) : super(id);
}

// custom <library repo>
// end <library repo>
