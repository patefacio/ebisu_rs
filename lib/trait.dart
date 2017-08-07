library ebisu_rs.trait;

import 'package:ebisu/ebisu.dart';
import 'package:ebisu_rs/entity.dart';
import 'package:ebisu_rs/generic.dart';
import 'package:ebisu_rs/type.dart';

export 'package:ebisu_rs/generic.dart';
export 'package:ebisu_rs/type.dart';

// custom <additional imports>
// end <additional imports>

class Parm extends RsEntity implements HasCode {
  RsType type;

  // custom <class Parm>

  get children => new Iterable<Parm>.generate(0);

  get code => '${id.snake} : ${type.code}';

  // end <class Parm>

  Parm(dynamic id) : super(id);
}

class Fn extends RsEntity with IsPub, Generic implements HasCode {
  List<Parm> parms = [];
  RsType returnType = UnitType;

  // custom <class Fn>

  Iterable<Entity> get children => new List<Parm>.from(parms, growable: false);

  String get code => brCompact([
        '${pubDecl}fn $name($_parmsText) -> $returnType {',
        '}',
      ]);

  set returns(dynamic rt) => returnType = rt is String
      ? new UserDefinedType(rt)
      : rt is RsType
          ? rt
          : throw '*fn* returns setter requires [String] or [RsType]';

  String get name => id.snake;

  String get _parmsText => parms.map((p) => p.code).join(', ');

  // end <class Fn>

  Fn(dynamic id) : super(id);
}

class Trait extends RsEntity with IsPub, Generic implements HasCode {
  List<Fn> functions = [];

  // custom <class Trait>

  Iterable<Entity> get children =>
      new List<Fn>.from(functions, growable: false);

  String get code => 'TODO';

  // end <class Trait>

  Trait(dynamic id) : super(id);
}

// custom <library trait>

Fn fn(dynamic id) => new Fn(id);

// end <library trait>
