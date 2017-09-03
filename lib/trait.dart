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

  get lifetimeDecl => isMutable ? 'mut $_lifetimeDecl' : _lifetimeDecl;

  get _lifetimeDecl => '${id.snake} : ${type.lifetimeDecl}';

  get code => isMutable ? 'mut $_decl' : _decl;

  get _decl => '${id.snake} : ${type.code}';

  // end <class Parm>

}

class SelfParm extends Parm {
  // custom <class SelfParm>

  SelfParm() : super('self', 'Self');

  get lifetimeDecl => "self";

  get code => 'self';

  // end <class SelfParm>

}

class SelfRefParm extends Parm {
  // custom <class SelfRefParm>

  SelfRefParm() : super('self', ref('Self'));

  get lifetimeDecl => "&'a self";

  get code => '& self';

  // end <class SelfRefParm>

}

class SelfRefMutableParm extends Parm {
  // custom <class SelfRefMutableParm>

  SelfRefMutableParm() : super('self', mref('Self'));

  get lifetimeDecl => "&'a mut self";

  get code => '& mut self';

  // end <class SelfRefMutableParm>

}

class Fn extends RsEntity with IsPub, Generic, HasAttributes, HasCodeBlock {
  List<Parm> get parms => _parms;
  RsType get returnType => _returnType;

  /// Document return type
  String returnDoc;
  set codeBlock(CodeBlock codeBlock) => _codeBlock = codeBlock;

  /// If true lifetimes are elided, indicating rust has similar defaults
  bool elideLifetimes = false;

  // custom <class Fn>

  /// Construct a Fn.
  ///
  /// *id* - Symbol or String identifying function
  ///
  /// *parms* - Parameters to the function
  ///
  /// *returnType* - Type function returns - default is ()
  Fn(dynamic id, [Iterable<Parm> parms, dynamic returnType = UnitType])
      : _returnType = returnType,
        super(id) {
    if (parms != null) {
      this.parms = parms;
    }
  }

  get codeBlock => _codeBlock ?? (_codeBlock = new CodeBlock(id.snake));

  withCodeBlock(void codeBlock(CodeBlock)) => codeBlock(this.codeBlock);

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
        _codeBlock == null
            ? '$signature;'
            : brCompact(
                ['$signature {', indentBlock(_codeBlock.toString()), '}'])
      ]);

  String get signature => elideLifetimes
      ? signatureNoLifetimes
      : '${pubDecl}fn $name$genericDecl($_parmsText) -> ${_returnType.lifetimeDecl}';

  String get signatureNoLifetimes =>
      '${pubDecl}fn $name$genericDeclNoLifetimes($_parmsTextNoLifetimes) -> ${_returnType.code}';

/* TODO: revisit if possible to elide lifetimes in sane way
  String get signature => _returnType.lifetimes.isNotEmpty?
      '${pubDecl}fn $name$genericDecl($_parmsText) -> ${_returnType.lifetimeDecl}' :
      '${pubDecl}fn $name$genericDeclNoLifetimes($_parmsText) -> ${returnType.lifetimeDecl}';
*/

  String get _docComment {
    var fnDoc = [
      descr == null
          ? 'TODO: comment fn ${id.snake}:${_codeBlock!=null? _codeBlock.tag : "no-body-tag"}'
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

  String get _parmsText => parms.map((p) => p.lifetimeDecl).join(', ');

  String get _parmsTextNoLifetimes => parms.map((p) => p.code).join(', ');

  addParm(dynamic id, [dynamic type]) => _parms.add(new Parm(id, type));

  copy() => new Fn._copy(this);

  Fn._copy(Fn other)
      : _parms = other._parms == null ? null : (new List.from(other._parms)),
        _returnType = other._returnType?.copy(),
        returnDoc = other.returnDoc,
        elideLifetimes = other.elideLifetimes,
        super(other.id) {
    doc = other.doc;
    _codeBlock = other._codeBlock?.copy();
  }

  // end <class Fn>

  List<Parm> _parms = [];
  RsType _returnType = UnitType;
  CodeBlock _codeBlock;
}

class Trait extends RsEntity
    with IsPub, Generic, HasAttributes, HasAssociatedTypes, HasCodeBlock
    implements HasCode {
  List<Fn> functions = [];

  /// List of subtraits - either as String or modeled Trait
  List<dynamic> subTraits = [];

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
        '$_traitDecl$boundsDecl {',
        indentBlock(br([
          associatedTypeDecls,
          br([functions.map((fn) => fn.code)]),
          codeBlock?.toString()
        ])),
        '}'
      ]);

  _getSubtrateName(s) => s is String ? s : s.name;

  String get _traitDecl =>
      'trait $name${genericDecl}' +
      (subTraits.isNotEmpty
          ? ': ' + subTraits.map((st) => _getSubtrateName(st)).join(' + ')
          : '');

  String get name => id.capCamel;

  // end <class Trait>

}

// custom <library trait>

/// Create a Fn.
///
/// *id* - Symbol or String identifying function
///
/// *parms* - Parameters to the function
///
/// *returnType* - Type function returns - default is ()
Fn fn(dynamic id, [Iterable<dynamic> parms, dynamic returnType = UnitType]) =>
    new Fn(id, parms, returnType);

Parm parm(dynamic id, dynamic type, [bool isMutable = false]) =>
    new Parm(id, type, isMutable);

Trait trait(dynamic id) => new Trait(id);

final Parm self = new SelfParm();
final Parm selfRef = new SelfRefParm();
final Parm selfRefMutable = new SelfRefMutableParm();

// end <library trait>
