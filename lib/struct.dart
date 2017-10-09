library ebisu_rs.struct;

import 'package:ebisu/ebisu.dart';
import 'package:ebisu_rs/entity.dart';
import 'package:ebisu_rs/field.dart';
import 'package:ebisu_rs/generic.dart';
import 'package:ebisu_rs/macro.dart';
import 'package:ebisu_rs/type.dart';
import 'package:logging/logging.dart';
import 'package:quiver/iterables.dart';

export 'package:ebisu_rs/field.dart';
export 'package:ebisu_rs/generic.dart';
export 'package:ebisu_rs/macro.dart';
export 'package:ebisu_rs/type.dart';
export 'package:quiver/iterables.dart';

// custom <additional imports>

export 'package:ebisu_rs/field.dart';

// end <additional imports>

final Logger _logger = new Logger('struct');

/// Base class for various struct types (struct, tuple_struct, unit_struct)
abstract class StructType extends RsEntity
    with IsPub, Derives
    implements HasCode {
  StructType(dynamic id) : super(id);
}

class Struct extends StructType with Generic {
  List<Field> fields = [];

  // custom <class Struct>

  @override
  get children => concat([lifetimes, typeParms, fields, genericChildren]);

  String toString() => 'struct($unqualifiedName)';

  @override
  String get unqualifiedName => id.capCamel;

  @override
  onOwnershipEstablished() {
    _logger.info("Ownership of struct ${id}:${runtimeType}");
    if (lifetimes.isEmpty) {
      inferLifetimes();
    }
  }

  inferLifetimes() {
    lifetimes =
        new Set<Lifetime>.from(concat(fields.map((m) => m.lifetimes)).toList())
            .toList()
              ..sort();
  }

  @override
  GenericInst inst(
          {Iterable typeArgs = const [], Iterable lifetimes = const []}) =>
      new StructInst(this)
        ..typeArgs = typeArgs
        ..lifetimes = lifetimes;

  @override
  String get code => brCompact([
        tripleSlashComment(doc?.toString() ?? 'TODO: comment struct `$genericName`'),
        derives,
        '${pubDecl}struct $unqualifiedName${genericDecl}$boundsDecl {',
        indentBlock(br(fields.map((field) => field.code), ',\n')),
        '}'
      ]);

  // end <class Struct>

  Struct(dynamic id) : super(id);
}

class StructInst extends GenericInst {
  Struct get struct => _struct;

  // custom <class StructInst>

  StructInst(this._struct);

  @override
  String get name => struct.unqualifiedName;

  @override
  String get lifetimeDecl => genericName;

  @override
  copy() => new StructInst(_struct)
    ..lifetimes = new List.from(lifetimes)
    ..typeArgs = new List.from(typeArgs);

  // end <class StructInst>

  Struct _struct;
}

/// Tuple struct
class TupleStruct extends StructType with Generic {
  // custom <class TupleStruct>

  @override
  Iterable<RsEntity> get children => genericChildren;

  @override
  String get code => brCompact([
        tripleSlashComment(doc?.toString() ?? 'TODO: Comment TupleStruct(`$genericName`)'),
        '${pubDecl}struct ${unqualifiedName}$boundsDecl {',
        '}',
      ]);

  @override
  GenericInst inst(
          {Iterable typeArgs = const [], Iterable lifetimes = const []}) =>
      new TupleStructInst(this)
        ..typeArgs = typeArgs
        ..lifetimes = lifetimes;

  @override
  String get unqualifiedName => id.capCamel;

  // end <class TupleStruct>

  TupleStruct(dynamic id) : super(id);
}

class TupleStructInst extends GenericInst {
  TupleStruct get tupleStruct => _tupleStruct;

  // custom <class TupleStructInst>

  @override
  String get name => tupleStruct.unqualifiedName;

  TupleStructInst(this._tupleStruct);

  @override
  copy() => new TupleStructInst(tupleStruct)
    ..lifetimes = new List.from(lifetimes)
    ..typeArgs = new List.from(typeArgs);

  // end <class TupleStructInst>

  TupleStruct _tupleStruct;
}

/// Unit struct
class UnitStruct extends StructType {
  // custom <class UnitStruct>

  Iterable<RsEntity> get children => new Iterable.empty();

  @override
  String get code => brCompact([
        tripleSlashComment(doc?.toString() ?? 'TODO: Comment UnitStruct(`$name`)'),
        '${pubDecl}struct $name;'
      ]);

  String get name => id.capCamel;

  // end <class UnitStruct>

  UnitStruct(dynamic id) : super(id);
}

// custom <library struct>

/// Creates a [Struct].
///
/// Creates a [Struct] instance identified by [id], which may be a symbol or string.
/// Returns new [Struct].
///
Struct struct(dynamic id) => new Struct(id);

/// Creates a _public_ [Struct].
///
/// Creates a _public_ [Struct] instance identified by [id], which may be a symbol or string.
/// Returns new [Struct].
///
Struct pubStruct(dynamic id) => new Struct(id)..isPub = true;

/// Creates a [UnitStruct].
///
/// Creates a [UnitStruct] instance identified by [id], which may be a symbol or string.
/// Returns new [UnitStruct].
///
UnitStruct ustruct(dynamic id) => new UnitStruct(id);

/// Creates a _publid_ [UnitStruct].
///
/// Creates a _public_ [UnitStruct] instance identified by [id], which may be a symbol or string.
/// Returns new [UnitStruct].
///
UnitStruct pubUstruct(dynamic id) => new UnitStruct(id)..isPub = true;

/// Creates a [TupleStruct].
///
/// Creates a [TupleStruct] instance identified by [id], which may be a symbol or string.
/// Returns new [TupleStruct].
///
TupleStruct tstruct(dynamic id) => new TupleStruct(id);

/// Creates a _public_ [TupleStruct].
///
/// Creates a _public_ [TupleStruct] instance identified by [id], which may be a symbol or string.
/// Returns new [TupleStruct].
///
TupleStruct pubTstruct(dynamic id) => new TupleStruct(id)..isPub = true;

// end <library struct>
