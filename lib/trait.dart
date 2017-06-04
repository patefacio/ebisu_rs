library ebisu_rs.trait;

import 'package:ebisu/ebisu.dart';
import 'package:ebisu_rs/entity.dart';
import 'package:id/id.dart';

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

  Parm(id) : super(id);
}

class Fn extends RsEntity with IsPub implements HasCode {
  List<Parm> parms = [];
  Type returnType;

  // custom <class Fn>

  get children => new List<Parm>.from(parms, growable: false);

  get code => brCompact([
        '${pubDecl}fn $name($_parmsText) -> $returnType {',
        '}',
      ]);

  get name => id.snake;

  get _parmsText => parms.map((p) => p.code).join(', ');

  // end <class Fn>

  Fn(id) : super(id);
}

class Trait extends RsEntity with IsPub implements HasCode {
  List<Fn> functions = [];

  // custom <class Trait>

  get children => new List<Fn>.from(functions, growable: false);

  // end <class Trait>

  Trait(id) : super(id);
}

// custom <library trait>
// end <library trait>
