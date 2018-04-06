library ebisu_rs.struct;

import 'package:ebisu/ebisu.dart';
import 'package:ebisu_rs/attribute.dart';
import 'package:ebisu_rs/entity.dart';
import 'package:ebisu_rs/field.dart';
import 'package:ebisu_rs/generic.dart';
import 'package:ebisu_rs/impl.dart';
import 'package:ebisu_rs/macro.dart';
import 'package:ebisu_rs/trait.dart';
import 'package:ebisu_rs/type.dart';
import 'package:logging/logging.dart';
import 'package:quiver/iterables.dart';

export 'package:ebisu_rs/attribute.dart';
export 'package:ebisu_rs/field.dart';
export 'package:ebisu_rs/generic.dart';
export 'package:ebisu_rs/impl.dart';
export 'package:ebisu_rs/macro.dart';
export 'package:ebisu_rs/trait.dart';
export 'package:ebisu_rs/type.dart';
export 'package:quiver/iterables.dart';

// custom <additional imports>

export 'package:ebisu_rs/field.dart';

// end <additional imports>

final Logger _logger = new Logger('struct');

/// Base class for various struct types (struct, tuple_struct, unit_struct)
abstract class StructType extends RsEntity
    with IsPub, Derives, HasAttributes
    implements HasCode {
  /// The implementation for the struct
  set impl(TypeImpl impl) => _impl = impl;

  /// Implementations of traits for the struct
  set traitImpls(List<TraitImpl> traitImpls) => _traitImpls = traitImpls;

  // custom <class StructType>

  bool get hasImpl => _impl != null;

  TypeImpl get impl {
    return _impl ?? (_impl = new TypeImpl(rsType(id)));
  }

  @override
  Iterable<RsEntity> get children =>
      _impl == null ? new Iterable.empty() : [impl];

  // end <class StructType>

  StructType(dynamic id) : super(id);

  TypeImpl _impl;
  List<TraitImpl> _traitImpls = [];
}

class Struct extends StructType with Generic {
  List<Field> fields = [];

  /// If set, all fields are read-only
  bool isEncapsulated = false;

  // custom <class Struct>

  @override
  get children =>
      concat([lifetimes, typeParms, fields, genericChildren, super.children]);

  String toString() => 'struct($unqualifiedName)';

  withField(Object id, f(Field)) {
    id = makeId(id);
    f(fields.firstWhere((f) => f.id == id));
  }

  withFields(Iterable<Object> ids, f(Field)) =>
      ids.forEach((id) => withField(id, f));

  @override
  String get unqualifiedName => id.capCamel;

  setAccessors() {
    if (isEncapsulated) {
      fields.forEach((Field field) {
        if (field.access == null || field.access != rw) {
          field.access = ro;
        }
      });
    }
  }

  @override
  onOwnershipEstablished() {
    _logger.info("Ownership of struct ${id}:${runtimeType}");

    if (lifetimes.isEmpty) {
      inferLifetimes();
    }
  }

  bool get hasAccessors => fields.any((f) => f.access != null);

  List<Fn> get accessors {
    List<Fn> results = [];
    fields.where((f) => f.access != null).forEach((Field field) {
      if (field.access == ro || field.access == rw) {
        results.add((pubFn(field.id, [selfRef])
          ..doc = 'Read accessor for `${field.id.snake}`'
          ..body = (field.byRef ? '&' : '') + 'self.${field.id.snake}'
          ..returns = field.byRef ? ref(field.type) : field.type
          ..returnDoc = 'Current state for `${field.id.snake}`'
          ..isUnitTestable = false
          ..isInline = true));
      }

      if (field.access == wo || field.access == rw) {
        results.add((pubFn('set_${field.id.snake}', [
          selfRefMutable,
          parm(field.id, field.byRef ? ref(field.type) : field.type)
            ..doc = 'New value for `${field.id.snake}`'
        ])
          ..doc = 'Write accessor for `${field.id.snake}`'

          /// TODO: determine if this should be copy/clone to work
          ..body = 'self.${field.id.snake} = ${field.id.snake};'
          ..isUnitTestable = false
          ..isInline = true));
      }
    });
    return results;
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
        tripleSlashComment(
            doc?.toString() ?? 'TODO: comment struct `$genericName`'),
        externalAttrs,
        derives,
        '${pubDecl}struct $unqualifiedName${genericDecl}$boundsDecl {',
        indentBlock(br(fields.map((field) => field.code), ',\n')),
        '}',
        _impl?.code
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
  List<RsType> get fieldTypes => _fieldTypes;

  // custom <class TupleStruct>

  @override
  onOwnershipEstablished() {
    _logger.info("Ownership of struct ${id}:${runtimeType}");
    if (lifetimes.isEmpty) {
      _inferLifetimes();
    }
  }

  _inferLifetimes() {
    lifetimes = new Set<Lifetime>.from(
            concat(fieldTypes.map((m) => m.lifetimes)).toList())
        .toList()
          ..sort();
  }

  @override
  Iterable<RsEntity> get children => concat([genericChildren, super.children]);

  @override
  String get code => brCompact([
        tripleSlashComment(
            doc?.toString() ?? 'TODO: Comment TupleStruct(`$genericName`)'),
        derives,
        combine([
          '${pubDecl}struct ${unqualifiedName}${genericDecl}$boundsDecl(',
          fieldTypes.map((ft) => ft.lifetimeDecl).join(', '),
          ');'
        ]),
      ]);

  @override
  GenericInst inst(
          {Iterable typeArgs = const [], Iterable lifetimes = const []}) =>
      new TupleStructInst(this)
        ..typeArgs = typeArgs
        ..lifetimes = lifetimes;

  @override
  String get unqualifiedName => id.capCamel;

  set fieldTypes(Iterable it) => _fieldTypes = it.map(rsType).toList();

  // end <class TupleStruct>

  TupleStruct(dynamic id) : super(id);

  List<RsType> _fieldTypes = [];
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

  @override
  String get code => brCompact([
        tripleSlashComment(
            doc?.toString() ?? 'TODO: Comment UnitStruct(`$name`)'),
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

/// Creates a _public_ [UnitStruct].
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

/// Creates a [TupleStruct] with one type, also called a _"NewType"_.
///
/// Creates a _"NewType"_ instance identified by [id], which may be a symbol or string.
/// Returns new [TupleStruct].
///
TupleStruct newType(dynamic id, dynamic type) =>
    new TupleStruct(id)..fieldTypes = [rsType(type)];

/// Creates a _public_ [TupleStruct] with one type, also called a _"NewType"_.
///
/// Creates a _"NewType"_ instance identified by [id], which may be a symbol or string.
/// Returns new [TupleStruct].
///
TupleStruct pubNewType(dynamic id, dynamic type) => new TupleStruct(id)
  ..fieldTypes = [rsType(type)]
  ..isPub = true;

// end <library struct>
