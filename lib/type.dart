library ebisu_rs.type;

import 'package:ebisu_rs/entity.dart';
import 'package:quiver/iterables.dart';

// custom <additional imports>
// end <additional imports>

abstract class RsType implements HasCode {
  // custom <class RsType>

  const RsType();

  bool get isRef => false;

  bool get isMref => false;

  bool get isRefType => false;

  String get scopedDecl => toString();

  Iterable<String> get lifetimes => new Iterable.empty();

  // end <class RsType>

}

class Str extends RsType {
  // custom <class Str>

  @override
  String get code => 'String';

  // end <class Str>

}

class BuiltInType extends RsType {
  final String typeName;

  // custom <class BuiltInType>

  const BuiltInType(this.typeName);

  @override
  String get code => typeName;

  @override
  toString() => typeName;

  // end <class BuiltInType>

}

class RsString extends RsType {
  // custom <class RsString>
  // end <class RsString>

}

class Int extends RsType {
  final int size;
  final bool isSigned;

  // custom <class Int>

  const Int(this.size, [this.isSigned = true]);

  @override
  toString() => '${isSigned? "i":"u"}$size';

  // end <class Int>

}

class Float extends RsType {
  final int size;

  // custom <class Float>

  const Float(this.size);

  @override
  toString() => 'f$size';

  // end <class Float>

}

class UserDefinedType extends RsType {
  final String name;

  // custom <class UserDefinedType>

  UserDefinedType(this.name);

  toString() => name;

  // end <class UserDefinedType>

}

abstract class RefType extends RsType {
  final RsType referent;
  String lifetime;

  // custom <class RefType>

  RefType(this.referent, [this.lifetime = '']);

  bool get isRefType => true;

  String get scopedDecl {
    if (lifetime.isNotEmpty) {
      return '& \'$lifetime $_mutTag${referent.scopedDecl}';
    } else {
      return toString();
    }
  }

  Iterable<String> get lifetimes => lifetime.isNotEmpty
      ? concat(<Iterable<String>>[
          [lifetime],
          referent.lifetimes
        ]) as Iterable<String>
      : referent.lifetimes;

  String get _mutTag => isMutable ? 'mut ' : '';

  @override
  toString() => '& $_mutTag$referent';

  bool get isMutable => false;

  // end <class RefType>

}

class Ref extends RefType {
  // custom <class Ref>

  Ref(RsType referent, [String lifetime]) : super(referent, lifetime);

  bool get isRef => true;

  // end <class Ref>

}

class Mref extends RefType {
  // custom <class Mref>

  Mref(RsType referent, [String lifetime]) : super(referent, lifetime);

  bool get isMutable => true;

  bool get isMref => true;

  // end <class Mref>

}

// custom <library type>

const string = const BuiltInType('String');
const str = const BuiltInType('str');
const isize = const BuiltInType('isize');
const usize = const BuiltInType('usize');
const i8 = const Int(8);
const i16 = const Int(16);
const i32 = const Int(32);
const i64 = const Int(64);

const u8 = const Int(8, false);
const u16 = const Int(16, false);
const u32 = const Int(32, false);
const u64 = const Int(64, false);

const f32 = const Float(32);
const f64 = const Float(64);

Ref ref(RsType type, [String lifetime]) => new Ref(type, lifetime);

Mref mref(RsType type, [String lifetime]) => new Mref(type, lifetime);

RsType rsType(dynamic details) => details is RsType
    ? details
    : details is String
        ? new UserDefinedType(details)
        : throw 'Unsupported rstype ${details.runtimeType}';

// end <library type>

void main([List<String> args]) {
// custom <main>

  print("DONE");

  print(ref(mref(ref(i8))));

// end <main>
}
