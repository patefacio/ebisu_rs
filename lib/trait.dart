library ebisu_rs.trait;

import 'package:ebisu/ebisu.dart';
import 'package:ebisu_rs/entity.dart';

// custom <additional imports>
// end <additional imports>

class Type implements HasCode {
  String type;

  // custom <class Type>

  get code => '$type';

  // end <class Type>

}

class Parm extends RsEntity implements HasCode {
  Type type;

  // custom <class Parm>

  get children => new Iterable<Parm>.generate(0);

  get code => '${id.snake} : ${type.code}';

  // end <class Parm>

  Parm(dynamic id) : super(id);
}

class Fn extends RsEntity with IsPub implements HasCode {
  List<Parm> parms = [];
  Type returnType;

  // custom <class Fn>

  Iterable<Entity> get children => new List<Parm>.from(parms, growable: false);

  String get code => brCompact([
        '${pubDecl}fn $name($_parmsText) -> $returnType {',
        '}',
      ]);

  String get name => id.snake;

  String get _parmsText => parms.map((p) => p.code).join(', ');

  // end <class Fn>

  Fn(dynamic id) : super(id);
}

class Trait extends RsEntity with IsPub implements HasCode {
  List<Fn> functions = [];

  // custom <class Trait>

  Iterable<Entity> get children =>
      new List<Fn>.from(functions, growable: false);

  String get code => 'TODO';

  // end <class Trait>

  Trait(dynamic id) : super(id);
}

// custom <library trait>
// end <library trait>
