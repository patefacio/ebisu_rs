library ebisu_rs.trait;

import 'package:ebisu/ebisu.dart' hide codeBlock;
import 'package:ebisu_rs/attribute.dart';
import 'package:ebisu_rs/entity.dart';
import 'package:ebisu_rs/generic.dart';
import 'package:ebisu_rs/type.dart';

export 'package:ebisu_rs/attribute.dart';
export 'package:ebisu_rs/entity.dart';
export 'package:ebisu_rs/generic.dart';
export 'package:ebisu_rs/type.dart';

// custom <additional imports>
// end <additional imports>

class Parm extends RsEntity implements HasCode {
  final RsType type;
  bool isMutable = false;

  // custom <class Parm>

  Parm(dynamic id, dynamic type, [bool this.isMutable = false])
      : type = rsType(type),
        super(id);

  get children => new Iterable<Parm>.generate(0);

  get code => isMutable ? 'mut $_decl' : _decl;

  get _decl => '${id.snake} : ${type.lifetimeDecl}';

  // end <class Parm>

}

class SelfParm extends Parm {
  // custom <class SelfParm>

  SelfParm() : super('self', 'Self');

  get code => 'self';

  // end <class SelfParm>

}

class SelfRefParm extends Parm {
  // custom <class SelfRefParm>

  SelfRefParm() : super('self', ref('Self'));

  get code => '& self';

  // end <class SelfRefParm>

}

class SelfRefMutableParm extends Parm {
  // custom <class SelfRefMutableParm>

  SelfRefMutableParm() : super('self', mref('Self'));

  get code => '& mut self';

  // end <class SelfRefMutableParm>

}

class Fn extends RsEntity
    with IsPub, Generic, HasAttributes, HasCodeBlock
    implements HasCode {
  List<Parm> get parms => _parms;
  RsType get returnType => _returnType;

  /// Document return type
  String returnDoc;

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
        codeBlock == null
            ? '$signature;'
            : brCompact(
                ['$signature {', indentBlock(codeBlock.toString()), '}'])
      ]);

  String get signature =>
      '${pubDecl}fn $name$genericDecl($_parmsText) -> ${_returnType.lifetimeDecl}';

/* TODO: revisit if possible to elide lifetimes in sane way
  String get signature => _returnType.lifetimes.isNotEmpty?
      '${pubDecl}fn $name$genericDecl($_parmsText) -> ${_returnType.lifetimeDecl}' :
      '${pubDecl}fn $name$genericDeclNoLifetimes($_parmsText) -> ${returnType.lifetimeDecl}';
*/

  String get _docComment {
    var fnDoc = [
      descr == null
          ? 'TODO: comment fn ${id.snake}:${codeBlock!=null? codeBlock.tag : "no-body-tag"}'
          : descr
    ];
    return tripleSlashComment(chomp(br([
      fnDoc,
      brCompact(concat([
        parms.where((p) => p.id.snake != 'self').map((p) =>
            ' * `${p.id.snake}` - ${p.doc == null? "TODO: comment parm" : p.doc}'),
        [
          _returnType != null
              ? ' * return - ${returnDoc ?? "TODO: document return"}'
              : null
        ]
      ]))
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
        super(other.id) {
    codeBlock = other.codeBlock?.copy();
  }

  // end <class Fn>

  List<Parm> _parms = [];
  RsType _returnType = UnitType;
}

class Trait extends RsEntity
    with IsPub, Generic, HasAttributes, HasAssociatedTypes, HasCodeBlock
    implements HasCode {
  List<Fn> functions = [];

  // custom <class Trait>

  Trait(dynamic id) : super(id) {
    codeBlock = new CodeBlock('trait_${this.id.snake}');
  }

  @override
  onOwnershipEstablished() {}

  Iterable<Entity> get children =>
      new List<Fn>.from(functions, growable: false);

  String get code => brCompact([
        tripleSlashComment(
            doc?.toString() ?? 'TODO: comment trait ${id.capCamel}'),
        externalAttrs,
        'trait $name${genericDecl} {',
        indentBlock(br([
          associatedTypeDecls,
          br([functions.map((fn) => fn.code)]),
          codeBlock?.toString()
        ])),
        '}'
      ]);

  String get name => id.capCamel;

  // end <class Trait>

}

// custom <library trait>

Fn fn(dynamic id, [Iterable<dynamic> parms, dynamic returnType = UnitType]) =>
    new Fn(id, parms, returnType);

Parm parm(dynamic id, dynamic type, [bool isMutable = false]) =>
    new Parm(id, type, isMutable);

Trait trait(dynamic id) => new Trait(id);

final Parm self = new SelfParm();
final Parm selfRef = new SelfRefParm();
final Parm selfRefMutable = new SelfRefMutableParm();

// end <library trait>
