library ebisu_rs.trait;

import 'package:ebisu/ebisu.dart';
import 'package:ebisu_rs/attribute.dart';
import 'package:ebisu_rs/entity.dart';
import 'package:ebisu_rs/generic.dart';
import 'package:ebisu_rs/type.dart';

export 'package:ebisu_rs/attribute.dart';
export 'package:ebisu_rs/generic.dart';
export 'package:ebisu_rs/type.dart';

// custom <additional imports>
// end <additional imports>

class Parm extends RsEntity implements HasCode {
  final RsType type;

  // custom <class Parm>

  Parm(dynamic id, dynamic type)
      : type = rsType(type),
        super(id);

  get children => new Iterable<Parm>.generate(0);

  get code => '${id.snake} : ${type.lifetimeDecl}';

  // end <class Parm>

}

class Fn extends RsEntity
    with IsPub, Generic, HasAttributes
    implements HasCode {
  List<Parm> get parms => _parms;
  RsType get returnType => _returnType;
  CodeBlock body;

  // custom <class Fn>

  Fn(dynamic id, [Iterable<Parm> parms, dynamic returnType = UnitType])
      : _returnType = returnType,
        super(id) {
    if (parms != null) {
      this.parms = parms;
    }
  }

  @override
  onOwnershipEstablished() {
    if (lifetimes.isEmpty) {
      lifetimes = new Set<Lifetime>.from(
              concat(parms.map<Iterable<Parm>>((parm) => parm.type.lifetimes)))
          .toList()
            ..sort();
    }
  }

  Iterable<Entity> get children => new List<Parm>.from(parms, growable: false);

  set parms(Iterable<Parm> parms) => _parms = new List.from(parms);

  set returnType(dynamic type) => _returnType = rsType(type);

  String get code => brCompact([
        _docComment,
        externalAttrs,
        body == null
            ? '$signature;'
            : brCompact(['$signature {', indentBlock(body.toString()), '}'])
      ]);

  String get signature =>
      '${pubDecl}fn $name$genericDecl($_parmsText) -> $returnType';

  String get _docComment {
    var fnDoc = [
      descr == null
          ? 'TODO: comment fn ${id.snake}:${body!=null? body.tag : "no-body-tag"}'
          : descr
    ];
    return tripleSlashComment(chomp(br([
      fnDoc,
      brCompact(parms.map((p) =>
          ' * `${p.id.snake}` - ${p.doc == null? "TODO: comment parm" : p.doc}'))
    ])));
  }

  set returns(dynamic rt) => returnType = rt is String
      ? new UserDefinedType(rt)
      : rt is RsType
          ? rt
          : throw '*fn* returns setter requires [String] or [RsType]';

  String get name => id.snake;

  String get _parmsText => parms.map((p) => p.code).join(', ');

  addParm(dynamic id, [dynamic type]) => _parms.add(new Parm(id, type));

  copy() => new Fn._copy(this);

  Fn._copy(Fn other)
      : _parms = other._parms == null ? null : (new List.from(other._parms)),
        _returnType = other._returnType?.copy(),
        body = other.body?.copy(),
        super(other.id);

  // end <class Fn>

  List<Parm> _parms = [];
  RsType _returnType = UnitType;
}

class Trait extends RsEntity
    with IsPub, Generic, HasAttributes, HasAssociatedTypes
    implements HasCode {
  List<Fn> functions = [];

  // custom <class Trait>

  Iterable<Entity> get children =>
      new List<Fn>.from(functions, growable: false);

  String get code => brCompact([
        tripleSlashComment(
            doc?.toString() ?? 'TODO: comment trait ${id.capCamel}'),
        externalAttrs,
        'trait $name${genericDecl} {',
        indentBlock(associatedTypeDecls),
        indentBlock(brCompact([functions.map((fn) => fn.code)])),
        '}'
      ]);

  String get name => id.capCamel;

  // end <class Trait>

  Trait(dynamic id) : super(id);
}

// custom <library trait>

Fn fn(dynamic id, [Iterable<dynamic> parms, dynamic returnType = UnitType]) =>
    new Fn(id, parms, returnType);

Parm parm(dynamic id, dynamic type) => new Parm(id, type);

Trait trait(dynamic id) => new Trait(id);

// end <library trait>
