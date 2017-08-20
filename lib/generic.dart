library ebisu_rs.generic;

import 'package:ebisu_rs/entity.dart';
import 'package:ebisu_rs/generic.dart';
import 'package:ebisu_rs/type.dart';
import 'package:id/id.dart';
import 'package:quiver/iterables.dart';

export 'package:ebisu_rs/entity.dart';
export 'package:ebisu_rs/generic.dart';
export 'package:ebisu_rs/type.dart';
export 'package:id/id.dart';
export 'package:quiver/iterables.dart';

// custom <additional imports>
// end <additional imports>

class Lifetime extends RsEntity implements HasCode, Comparable<Lifetime> {
  // custom <class Lifetime>
  get children => new Iterable.empty();

  @override
  get code => "'${id.snake}";

  Lifetime([dynamic id]) : super(id == null ? 'a' : id);

  Lifetime copy(Lifetime other) => new Lifetime(other.id);

  @override
  bool operator ==(Lifetime other) =>
      identical(this, other) || this.id == other.id;

  @override
  int get hashCode => id.hashCode;

  int compareTo(Lifetime other) => id.compareTo(other.id);

  // end <class Lifetime>

}

class TypeParm extends RsEntity implements HasCode {
  // custom <class TypeParm>

  get children => new Iterable.empty();

  @override
  get code => "${id.capCamel}";

  // end <class TypeParm>

  TypeParm(dynamic id) : super(id);
}

class Generic {
  List<Lifetime> get lifetimes => _lifetimes;
  List<TypeParm> get typeParms => _typeParms;

  // custom <class Generic>

  generic(Iterable<dynamic> lifetimes, Iterable<dynamic> typeParms) {
    this._lifetimes =
        lifetimes.map((lt) => lt is Lifetime ? lt : lifetime(lt)).toList();
    this._typeParms =
        typeParms.map((tp) => tp is TypeParm ? tp : typeParm(tp)).toList();
  }

  set lifetimes(Iterable<dynamic> lifetimes) =>
      _lifetimes = new List.from(lifetimes.map(lifetime));

  set typeParms(Iterable<dynamic> typeParms) =>
      _typeParms = new List.from(typeParms.map(typeParm));

  get children =>
      new List<RsEntity>.from(concat([lifetimes, typeParms]), growable: false);

  get genericDecl => lifetimes.isEmpty && typeParms.isEmpty
      ? ''
      : [
          '<',
          concat([
            lifetimes.map((lt) => lt.code),
            typeParms.map((parm) => parm.code)
          ]).join(', '),
          '>'
        ].join('');

  get genericDeclNoLifetimes => typeParms.isEmpty
      ? ''
      : [
          '<',
          concat([
            typeParms.map((parm) => parm.code)
          ]).join(', '),
          '>'
        ].join('');

  // end <class Generic>

  List<Lifetime> _lifetimes = [];
  List<TypeParm> _typeParms = [];
}

class GenericType extends RsType {
  RsType type;
  List<Id> get lifetimes => _lifetimes;
  List<RsType> get typeArgs => _typeArgs;

  // custom <class GenericType>

  GenericType(type, dynamic lifetimes, dynamic typeArgs) : type = rsType(type) {
    this.lifetimes = lifetimes;
    this.typeArgs = typeArgs;
  }

  set lifetimes(dynamic lifetimes) => _lifetimes = lifetimes is Iterable
      ? new List.from(lifetimes.map(makeRsId))
      : [makeRsId(lifetimes)];

  set typeArgs(dynamic typeArgs) => _typeArgs = typeArgs is Iterable
      ? new List.from(typeArgs.map((ta) => rsType(ta)))
      : [rsType(typeArgs)];

  copy() => new GenericType(this.type.copy(), new List.from(lifetimes),
      new List.from(typeArgs.map((t) => t.copy())));

  @override
  get code => [
        type.code,
        '<',
        concat([
          lifetimes.map((lt) => "'${lt.snake}"),
          typeArgs.map((ta) => ta.code)
        ]).join(', '),
        '>'
      ].join('');

  // end <class GenericType>

  List<Id> _lifetimes = [];
  List<RsType> _typeArgs = [];
}

// custom <library generic>

Lifetime lifetime([dynamic id]) => id is Lifetime ? id : new Lifetime(id);
TypeParm typeParm(dynamic id) => id is TypeParm ? id : new TypeParm(id);
GenericType genericType(type, dynamic lifetimes, dynamic typeArgs) =>
    new GenericType(type, lifetimes, typeArgs);

/// Generic with one or more lifetimes
const lgt = genericType;

/// Most common generic types have no lifetimes
GenericType gt(type, dynamic typeArgs) =>
    new GenericType(type, const [], typeArgs);

// end <library generic>
