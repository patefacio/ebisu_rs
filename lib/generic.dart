library ebisu_rs.generic;

import 'package:ebisu/ebisu.dart';
import 'package:ebisu_rs/entity.dart';
import 'package:ebisu_rs/trait.dart';
import 'package:ebisu_rs/type.dart';
import 'package:quiver/iterables.dart';

export 'package:ebisu_rs/entity.dart';
export 'package:ebisu_rs/type.dart';
export 'package:quiver/iterables.dart';

// custom <additional imports>
// end <additional imports>

class Lifetime extends RsEntity implements HasCode, Comparable<Lifetime> {
  // custom <class Lifetime>
  get children => new Iterable.empty();

  @override
  get code => "'${id.snake}";

  Lifetime([dynamic id]) : super(id == null ? 'a' : id);

  Lifetime copy() => new Lifetime(id);

  @override
  bool operator ==(other) => identical(this, other) || this.id == other.id;

  @override
  int get hashCode => id.hashCode;

  int compareTo(Lifetime other) => id.compareTo(other.id);

  toString() => code;

  // end <class Lifetime>

}

class TypeParm extends RsEntity with HasBounds implements HasCode {
  /// Default for the type for the `TypeParm`
  RsType get defaultType => _defaultType;

  // custom <class TypeParm>

  get children => new Iterable.empty();

  @override
  get code => '${id.capCamel}$_withDefault';

  get boundsDecl => '${id.capCamel} : ${super.boundsDecl}';

  set defaultType(dynamic defaultType) => _defaultType = rsType(defaultType);

  toString() => code;

  String get _withDefault =>
      _defaultType == null ? '' : ' = ${_defaultType.typeName}';

  // end <class TypeParm>

  TypeParm(dynamic id) : super(id);

  RsType _defaultType;
}

/// An item that is parameterized by [lifetimes] and [typeParms]
abstract class Generic {
  List<Lifetime> get lifetimes => _lifetimes;
  List<TypeParm> get typeParms => _typeParms;

  /// For bounds that are atypical - higher typed
  List<Object> fancyBounds = [];

  // custom <class Generic>

  /// The name of the [Generic] without the [genericDecl]
  String get unqualifiedName;

  /// The name of the [Generic] with the [genericDecl]
  String get genericName => '$unqualifiedName$genericDecl';

  generic(Iterable<dynamic> lifetimes, Iterable<dynamic> typeParms) {
    this.lifetimes = lifetimes;
    this.typeParms = typeParms;
  }

  GenericInst inst(
      {Iterable typeArgs = const [], Iterable lifetimes = const []});

  set lifetimes(Iterable<dynamic> lifetimes) =>
      _lifetimes = new List.from(lifetimes.map(lifetime));

  set typeParms(Iterable<dynamic> typeParms) =>
      _typeParms = new List.from(typeParms.map(typeParm));

  get genericChildren =>
      new List<RsEntity>.from(concat([lifetimes, typeParms]), growable: false);

  get hasBounds =>
      fancyBounds.isNotEmpty || _typeParms.any((tp) => tp.hasBounds);

  get boundsDecl => hasBounds
      ? brCompact([
          ' where ',
          concat([
            typeParms.where((tp) => tp.hasBounds).map((tp) => tp.boundsDecl),
            makeBounds(fancyBounds)
          ]).join(', ')
        ])
      : '';

  get genericDecl => lifetimes.isEmpty && typeParms.isEmpty
      ? ''
      : [
          '<',
          concat([
            lifetimes.map((lt) => lt.code),
            typeParms.map((parm) => parm.code)
          ]).join(', '),
          '>',
        ].where((term) => term != null).join('');

  get genericDeclNoLifetimes => typeParms.isEmpty
      ? ''
      : [
          '<',
          concat([typeParms.map((parm) => parm.code)]).join(', '),
          '>'
        ].join('');

  // end <class Generic>

  List<Lifetime> _lifetimes = [];
  List<TypeParm> _typeParms = [];
}

/// An instantiation of a generic
abstract class GenericInst extends RsType {
  /// Optional reference to generic being instantiated
  Generic generic;

  // custom <class GenericInst>

  String get name;

  @override
  get typeName => genericName;

  /// List of lifetimes parameterizing the [Generic]'s lifetimes
  Iterable<Lifetime> get lifetimes => _lifetimes ?? new Iterable.empty();

  /// List of types instantiating the [Generic]'s types
  Iterable<RsType> get typeArgs => _typeArgs ?? new Iterable.empty();

  set lifetimes(dynamic lifetimes) => _lifetimes = lifetimes is Iterable
      ? new List.from(lifetimes.map(lifetime))
      : [makeRsId(lifetimes)];

  set typeArgs(dynamic typeArgs) => _typeArgs = typeArgs is Iterable
      ? new List.from(typeArgs.map((ta) => rsType(ta)))
      : [rsType(typeArgs)];

  get genericName => [
        name,
        '<',
        concat([
          _lifetimes == null
              ? new Iterable.empty()
              : _lifetimes.map((lt) => "'${lt.id.snake}"),
          _typeArgs == null
              ? new Iterable.empty()
              : _typeArgs.map((ta) => ta.typeName)
        ]).join(', '),
        '>'
      ].join('');

  @override
  get lifetimeDecl => [
        name,
        '<',
        concat([
          _lifetimes == null
              ? new Iterable.empty()
              : _lifetimes.map((lt) => "'${lt.id.snake}"),
          _typeArgs == null
              ? new Iterable.empty()
              : _typeArgs.map((ta) => ta.lifetimeDecl)
        ]).join(', '),
        '>'
      ].join('');

  // end <class GenericInst>

  /// List of lifetimes parameterizing the [Generic]'s lifetimes
  List<Lifetime> _lifetimes;

  /// List of types instantiating the [Generic]'s types
  List<RsType> _typeArgs;
}

// custom <library generic>

Lifetime lifetime([dynamic id]) =>
    id is Lifetime ? id : new Lifetime(makeRsId(id));
TypeParm typeParm(dynamic id) => id is TypeParm ? id : new TypeParm(id);

// end <library generic>
