library ebisu_rs.repo;

import 'dart:io';
import 'package:ebisu/ebisu.dart';
import 'package:ebisu_rs/crate.dart';
import 'package:ebisu_rs/entity.dart';
import 'package:id/id.dart';
import 'package:path/path.dart';

// custom <additional imports>
// end <additional imports>

class Repo extends RsEntity {
  List<Crate> crates = [];
  set rootPath(String rootPath) => _rootPath = rootPath;

  // custom <class Repo>

  get children => []..addAll(crates);

  get rootPath =>
      _rootPath ??= dirname(dirname(absolute(Platform.script.toFilePath())));

  toString() =>
      brCompact(['Repo($id:$rootPath)', indentBlock(brCompact(crates))]);

  // end <class Repo>

  Repo(id) : super(id);

  String _rootPath;
}

// custom <library repo>

repo(id) => new Repo(id);

// end <library repo>
