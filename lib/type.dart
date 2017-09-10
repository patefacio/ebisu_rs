library ebisu_rs.type;

import 'dart:mirrors';
import 'package:ebisu/ebisu.dart';
import 'package:ebisu_rs/entity.dart';
import 'package:ebisu_rs/generic.dart';
import 'package:quiver/iterables.dart';

export 'package:ebisu_rs/entity.dart';
export 'package:ebisu_rs/generic.dart';
export 'package:quiver/iterables.dart';

// custom <additional imports>
// end <additional imports>

abstract class RsType implements HasCode {
  // custom <class RsType>

  RsType copy();

  const RsType();

  bool get isRef => false;

  bool get isMref => false;

  bool get isRefType => false;

  /// Returns type with lifetime attributes
  String get lifetimeDecl => toString();

  Iterable<Id> get lifetimes => new Iterable.empty();

  String toString() => code;

  // end <class RsType>

}

class BuiltInType extends RsType {
  final String typeName;

  // custom <class BuiltInType>

  const BuiltInType(this.typeName);

  @override
  String get code => typeName;

  copy() => this;

  // end <class BuiltInType>

}

class UserDefinedType extends RsType {
  final String name;

  // custom <class UserDefinedType>

  UserDefinedType(this.name);

  copy() => this;

  @override
  get code => name;

  // end <class UserDefinedType>

}

class RefType extends RsType {
  copy() => new RefType._copy(this);

  final RsType referent;
  Lifetime get lifetime => _lifetime;

  // custom <class RefType>

  RefType(dynamic referent, [dynamic lifetime])
      : referent = rsType(referent),
        _lifetime = lifetime is Lifetime ? lifetime : new Lifetime(lifetime);

  bool get isRefType => true;

  String get lifetimeDecl => ['&', lifetime.code, mut, referent.lifetimeDecl]
      .where((term) => term.isNotEmpty)
      .join(' ');

  Iterable<Lifetime> get lifetimes => lifetime != null
      ? concat(<Iterable<Lifetime>>[
          [lifetime],
          referent.lifetimes
        ])
      : referent.lifetimes;

  bool get isMutable => false;

  get mut => '';

  @override
  get code => "& $referent";

  // end <class RefType>

  RefType._copy(RefType other)
      : referent = other.referent?.copy(),
        _lifetime = other._lifetime?.copy();

  Lifetime _lifetime;
}

class Ref extends RefType {
  // custom <class Ref>

  Ref(dynamic referent, [dynamic lifetime]) : super(referent, lifetime);

  bool get isRef => true;

  // end <class Ref>

}

class Mref extends RefType {
  // custom <class Mref>

  Mref(dynamic referent, [dynamic lifetime]) : super(referent, lifetime);

  bool get isMutable => true;

  bool get isMref => true;

  get mut => 'mut';

  @override
  get code => "& mut $referent";

  // end <class Mref>

}

/// Rust type alias
class TypeAlias extends RsEntity with IsPub, Generic, HasCode {
  RsType aliased;

  // custom <class TypeAlias>

  @override
  onOwnershipEstablished() {
    if (lifetimes.isEmpty) {
      lifetimes = new Set<Lifetime>.from(aliased.lifetimes).toList()..sort();
    }
  }

  TypeAlias(dynamic id, dynamic aliased)
      : aliased = rsType(aliased),
        super(id);

  @override
  get code =>
      '${pubDecl}type ${id.capCamel}${genericDecl} = ${aliased.lifetimeDecl};';

  // end <class TypeAlias>

}

abstract class HasTypeAliases {
  List<TypeAlias> typeAliases = [];

  // custom <class HasTypeAliases>

  bool get hasTypeAliases => typeAliases.isNotEmpty;

  String get typeAliasDecls => typeAliases.map((ta) => ta.code).join('\n');

  // end <class HasTypeAliases>

}

/// Rust type alias
class AssociatedType extends RsEntity with IsPub, Generic, HasCode, HasBounds {
  // custom <class AssociatedType>

  AssociatedType(dynamic id) : super(id);

  @override
  get code => brCompact([
        tripleSlashComment(
            doc?.toString() ?? 'TODO: comment associated type ${id.snake}'),
        '${pubDecl}type ${id.capCamel}$boundsDecl;'
      ]);

  get boundsDecl => hasBounds? ': ${super.boundsDecl}' : '';

  // end <class AssociatedType>

}

abstract class HasAssociatedTypes {
  List<AssociatedType> get associatedTypes => _associatedTypes;

  // custom <class HasAssociatedTypes>

  set associatedTypes(Iterable<dynamic> associatedTypes) =>
      this._associatedTypes =
          new List.from(associatedTypes.map((t) => associatedType(t)));

  String get associatedTypeDecls =>
      _associatedTypes.map((t) => t.code).join('\n');

  // end <class HasAssociatedTypes>

  List<AssociatedType> _associatedTypes = [];
}

abstract class HasBounds {
  List<dynamic> get bounds => _bounds;

  // custom <class HasBounds>

  get boundsDecl =>
      bounds.map((bound) => bound is String ? bound : bound.name).join(' + ');

  set bounds(Iterable<dynamic> bounds) => _bounds = new List
      .from(bounds.map((bound) => bound
          is Id
      ? bound.capCamel
      : bound is String
          ? bound
          : throw new ArgumentError(
              'Bounds must be Id, String or Trait not ${bound.runtimeType}')));

  bool get hasBounds => bounds.isNotEmpty;

  // end <class HasBounds>

  List<dynamic> _bounds = [];
}

// custom <library type>

const char = const BuiltInType('char');
const string = const BuiltInType('String');
const str = const BuiltInType('str');
const isize = const BuiltInType('isize');
const usize = const BuiltInType('usize');
const i8 = const BuiltInType('i8');
const i16 = const BuiltInType('i16');
const i32 = const BuiltInType('i32');
const i64 = const BuiltInType('i64');

const u8 = const BuiltInType('u8');
const u16 = const BuiltInType('u16');
const u32 = const BuiltInType('u32');
const u64 = const BuiltInType('u64');

const f32 = const BuiltInType('f32');
const f64 = const BuiltInType('f64');
const bool_ = const BuiltInType('bool');

const UnitType = const BuiltInType('()');

/// Create a new [Ref] rust type (eg ref(i32) -> &i32).
/// 
/// [type] identifies the new type and is convertable from String, Id or Symbol.
/// [lifetime] may be provided 
/// 
Ref ref(dynamic type, [dynamic lifetime]) => new Ref(type, lifetime);

/// Create a new [Mref] rust type (eg mref(i32) -> & mut i32).
/// 
/// [type] identifies the new type and is convertable from String, Id or Symbol.
/// [lifetime] may be provided 
/// 
Mref mref(dynamic type, [dynamic lifetime]) => new Mref(type, lifetime);

/// Create a new rust type [RsType].
/// 
/// [type] identifies the new type and is convertable from String, Id or Symbol.
/// If an existing RsType is provided it is returned. Types based on string-like
/// [type] are created as [UserDefinedType] 
/// 
RsType rsType(dynamic type) => type is Symbol
    ? rsType(MirrorSystem.getName(type))
    : type is RsType
        ? type
        : type is String
            ? new UserDefinedType(type)
            : throw 'Unsupported rstype ${type.runtimeType}';

/// Create a TypeAlias.
/// 
/// [id] identifies the alias - convertable from String, Id, Symbol and
/// [aliased] is the item being aliased with a new identifier
/// 
TypeAlias typeAlias(dynamic id, [dynamic aliased]) =>
    new TypeAlias(id, aliased);

/// Create a TypeAlias that is public.
/// 
/// [id] identifies the alias - convertable from String, Id, Symbol and
/// [aliased] is the item being aliased with a new identifier
/// 
TypeAlias pubTypeAlias(dynamic id, [dynamic aliased]) =>
    new TypeAlias(id, aliased)..isPub = true;

AssociatedType associatedType(dynamic id) =>
    id is AssociatedType ? id : new AssociatedType(id);

// end <library type>

void main([List<String> args]) {
// custom <main>

  print("DONE");
  print(ref(mref(ref(i8))));

// end <main>
}
