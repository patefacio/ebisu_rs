library ebisu_rs.type;

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

  const RsType();

  bool get isRef => false;

  bool get isMref => false;

  bool get isRefType => false;

  /// Returns type with lifetime attributes
  String get lifetimeDecl => toString();

  Iterable<Lifetime> get lifetimes => new Iterable.empty();

  String toString() => code;

  // end <class RsType>

}

class BuiltInType extends RsType {
  final String typeName;

  // custom <class BuiltInType>

  const BuiltInType(this.typeName);

  @override
  String get code => typeName;

  // end <class BuiltInType>

}

class UserDefinedType extends RsType {
  final String name;

  // custom <class UserDefinedType>

  UserDefinedType(this.name);

  @override
  get code => name;

  // end <class UserDefinedType>

}

abstract class RefType extends RsType {
  final RsType referent;
  Lifetime get lifetime => _lifetime;

  // custom <class RefType>

  RefType(this.referent, [dynamic lifetime])
      : _lifetime = lifetime is Lifetime ? lifetime : new Lifetime(lifetime);

  bool get isRefType => true;

  String get lifetimeDecl => ['&', lifetime.code, mut, referent.lifetimeDecl]
      .where((term) => term.isNotEmpty)
      .join(' ');

  //"& $_lifetimeTag$_mutTag${referent.lifetimeDecl}";

  Iterable<Lifetime> get lifetimes => lifetime != null
      ? concat(<Iterable<Lifetime>>[
          [lifetime],
          referent.lifetimes
        ])
      : referent.lifetimes;

  bool get isMutable => false;

  get mut => '';

  // end <class RefType>

  Lifetime _lifetime;
}

class Ref extends RefType {
  // custom <class Ref>

  Ref(RsType referent, [dynamic lt])
      : super(referent, lt is Lifetime ? lt : lifetime(lt));

  bool get isRef => true;

  @override
  get code => "& $referent";

  // end <class Ref>

}

class Mref extends RefType {
  // custom <class Mref>

  Mref(RsType referent, [String lifetime]) : super(referent, lifetime);

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
  get code => 'type ${id.capCamel}${genericDecl} = ${aliased.lifetimeDecl};';

  // end <class TypeAlias>

}

// custom <library type>

const string = const BuiltInType('String');
const str = const BuiltInType('str');
const isize = const BuiltInType('isize');
const usize = const BuiltInType('usize');
const i8 = const BuiltInType('i8');
const i16 = const BuiltInType('i16');
const i32 = const BuiltInType('i32');
const i64 = const BuiltInType('i864');

const u8 = const BuiltInType('u8');
const u16 = const BuiltInType('u16');
const u32 = const BuiltInType('u32');
const u64 = const BuiltInType('u64');

const f32 = const BuiltInType('f32');
const f64 = const BuiltInType('f64');

const UnitType = const BuiltInType('()');

Ref ref(RsType type, [String lifetime]) => new Ref(type, lifetime);

Mref mref(RsType type, [String lifetime]) => new Mref(type, lifetime);

RsType rsType(dynamic type) => type is RsType
    ? type
    : type is String
        ? new UserDefinedType(type)
        : throw 'Unsupported rstype ${type.runtimeType}';

TypeAlias typeAlias(dynamic id, [dynamic aliased]) =>
    new TypeAlias(id, aliased);

// end <library type>

void main([List<String> args]) {
// custom <main>

  print("DONE");
  print(ref(mref(ref(i8))));

// end <main>
}
