library ebisu_rs.trait;

import 'package:ebisu/ebisu.dart' hide codeBlock;
import 'package:ebisu_rs/attribute.dart';
import 'package:ebisu_rs/constant.dart';
import 'package:ebisu_rs/entity.dart';
import 'package:ebisu_rs/generic.dart';
import 'package:ebisu_rs/static.dart';
import 'package:ebisu_rs/type.dart';
import 'package:logging/logging.dart';

export 'package:ebisu_rs/attribute.dart';
export 'package:ebisu_rs/constant.dart';
export 'package:ebisu_rs/entity.dart';
export 'package:ebisu_rs/generic.dart';
export 'package:ebisu_rs/static.dart';
export 'package:ebisu_rs/type.dart';

// custom <additional imports>
// end <additional imports>

final Logger _logger = new Logger('trait');

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

class Fn extends RsEntity
    with
        IsPub,
        Generic,
        HasStatics,
        HasConstants,
        HasAttributes,
        HasCodeBlock,
        IsUnitTestable {
  List<Parm> get parms => _parms;
  RsType get returnType => _returnType;

  /// Document return type
  String returnDoc;
  set codeBlock(CodeBlock codeBlock) => _codeBlock = codeBlock;

  /// If true lifetimes are elided.
  /// If false lifetimes are not elided.
  /// If null, lifetime elision rules apply
  bool elideLifetimes;

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

  GenericInst inst(
          {Iterable typeArgs = const [], Iterable lifetimes = const []}) =>
      throw 'GenericInst for Fn not implemented';

  get elisionRulesApply => (!returnType.isRefType ||
      parms.where((Parm p) => p.type.isRefType).length == 1 ||
      parms.any((Parm p) => p.type.isRefType && p.id.snake == 'self'));

  get codeBlock => _codeBlock ?? (_codeBlock = new CodeBlock('fn ${id.snake}'));

  withCodeBlock(void codeBlock(CodeBlock)) => codeBlock(this.codeBlock);

  @override
  onOwnershipEstablished() {
    _logger.info(
        'Ownership established for fn (isUnitTestable:$isUnitTestable) ${id}');
    if (lifetimes.isEmpty) {
      lifetimes = new Set<Lifetime>.from(
              concat(parms.map<Iterable<Parm>>((parm) => parm.type.lifetimes)))
          .toList()
            ..sort();
    }

    if (hasStatics) {
      codeBlock.snippets.insert(0, brCompact(staticDecls));
    }

    if (hasConstants) {
      codeBlock.snippets.insert(0, brCompact(constantDecls));
    }
  }

  Iterable<RsEntity> get children =>
      concat([genericChildren, constants, statics]);

  set parms(Iterable<Parm> parms) => _parms = new List.from(parms);

  set returnType(dynamic type) => _returnType = rsType(type);

  String get code => brCompact([
        !noComment ? _docComment : null,
        externalAttrs,
        _codeBlock == null
            ? '$signature;'
            : brCompact(
                ['$signature {', indentBlock(_codeBlock.toString()), '}'])
      ]);

  String get signature => elideLifetimes ?? elisionRulesApply
      ? signatureNoLifetimes
      : '${pubDecl}fn $name$genericDecl($_parmsText) -> ${_returnType.lifetimeDecl}$boundsDecl';

  String get signatureNoLifetimes =>
      '${pubDecl}fn $name$genericDeclNoLifetimes($_parmsTextNoLifetimes) -> ${_returnType.code}$boundsDecl';

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
          _returnType == null || _returnType.code == '()'
              ? null
              : ' * _return_ - ${returnDoc ?? "TODO: document return"}'
        ]
      ]))
    ])));
  }

  set returns(dynamic rt) => returnType = rt is String
      ? new UnmodeledType(rt)
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
    typeParms = new List.from(other.typeParms);
    // TODO: think about this: lifetimes = new List.from(other.lifetimes);
    doc = other.doc;
    _codeBlock = other._codeBlock?.copy();
    noComment = other.noComment;
    isUnitTestable = other.isUnitTestable;
  }

  // end <class Fn>

  List<Parm> _parms = [];
  RsType _returnType = UnitType;
  CodeBlock _codeBlock;
}

/// A rust trait.
///
/// This models a trait by defining the set of subtraits, associated types and functions.
/// The trait can be generic.
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

  GenericInst inst(
          {Iterable typeArgs = const [], Iterable lifetimes = const []}) =>
      new TraitInst(this)
        ..typeArgs = typeArgs
        ..lifetimes = lifetimes;

  @override
  onOwnershipEstablished() {}

  Iterable<RsEntity> get children =>
      concat([genericChildren, new List<Fn>.from(functions, growable: false)]);

  String get code => brCompact([
        !noComment
            ? tripleSlashComment(
                doc?.toString() ?? 'TODO: comment trait ${id.capCamel}')
            : null,
        externalAttrs,
        '$_traitDecl$boundsDecl {',
        indentBlock(br([
          associatedTypeDecls,
          br([functions.map((fn) => fn.code)]),
          codeBlock?.toString()
        ])),
        '}'
      ]);

  _getSubTraitName(s) => s is String ? s : s.genericName;

  String get _traitDecl =>
      '${pubDecl}trait $name${genericDecl}' +
      (subTraits.isNotEmpty
          ? ': ' + subTraits.map((st) => _getSubTraitName(st)).join(' + ')
          : '');

  String get name => id.capCamel;

  // end <class Trait>

}

class UnmodeledTrait {
  String name;

  // custom <class UnmodeledTrait>

  UnmodeledTrait(name);

  // end <class UnmodeledTrait>

}

/// An instance of a [Trait].
///
/// Only useful for traits with generics.
/// Traits without generics are themselves [TraitInst].
///
class TraitInst extends Object with GenericInst {
  /// Trait being instantiated
  Trait trait;

  // custom <class TraitInst>

  String get name => trait.name;

  Id get id => trait.id;

  get functions => trait.functions;

  get typeParms => trait.typeParms;

  get lifetimes => trait.lifetimes;

  get genericDeclNoLifetimes => trait.genericDeclNoLifetimes;

  TraitInst(dynamic trait) : trait = rsTrait(trait);

  // end <class TraitInst>

}

// custom <library trait>

/// Create a [Fn] identified by [id], which may be Symbol, String or Id
/// with function parameters [parms]. Returns the new [Fn].
Fn fn(dynamic id, [Iterable<dynamic> parms, dynamic returnType = UnitType]) =>
    new Fn(id, parms, returnType);

/// Create a _public_ [Fn] identified by [id], which may be Symbol, String or Id
/// with function parameters [parms]. Returns the new [Fn].
Fn pubFn(dynamic id,
        [Iterable<dynamic> parms, dynamic returnType = UnitType]) =>
    new Fn(id, parms, returnType)..isPub = true;

Parm parm(dynamic id, dynamic type, [bool isMutable = false]) =>
    new Parm(id, type, isMutable);

/// Create a [Trait] identified by [id], which may be Symbol, String or Id.
/// Returns the new [Trait].
Trait trait(dynamic id) => new Trait(id);

/// Create a _public_ [Trait] identified by [id],∏ which may be Symbol, String
/// or Id. Returns the new [Trait].
Trait pubTrait(dynamic id) => new Trait(id)..isPub = true;

final Parm self = new SelfParm();
final Parm selfRef = new SelfRefParm();
final Parm selfRefMutable = new SelfRefMutableParm();

Fn makeUnitTestFunction(Id id, [codeBlockTag]) {
  final function = new Fn('${id.snake}')
    ..noComment = true
    ..attrs = [idAttr('test')];

  if (codeBlockTag != null) {
    function.codeBlock.tag = codeBlockTag;
  }
  return function;
}

Trait rsTrait(dynamic trait) =>
    trait is Trait ? trait : new UnmodeledTrait(trait);

// end <library trait>
