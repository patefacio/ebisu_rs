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

class Struct extends RsEntity with IsPub, Derives, Generic implements HasCode {
  List<Field> fields = [];

  // custom <class Struct>

  get children => concat([lifetimes, typeParms, fields, genericChildren]);

  String toString() => 'struct($name)';

  String get name => id.capCamel;

  @override
  onOwnershipEstablished() {
    _logger.info("Ownership of struct ${id}:${runtimeType}");
    if (lifetimes.isEmpty) {
      lifetimes = new Set<Lifetime>.from(
              concat(fields.map<Iterable<Field>>((m) => m.lifetimes)).toList())
          .toList()
            ..sort();
    }

    for (final field in fields) {
      if (field.type.isRef) {}
    }
  }

  GenericInst inst(
          {Iterable typeArgs = const [], Iterable lifetimes = const []}) =>
      new StructInst(this)
        ..typeArgs = typeArgs
        ..lifetimes = lifetimes;

  String get template {
    var contents = chomp(brCompact([
      lifetimes.join(', '),
    ]));
    return contents.isNotEmpty ? '<$contents>' : '';
  }

  String get code => brCompact([
        tripleSlashComment(doc?.toString() ?? 'TODO: comment struct $id'),
        derives,
        '${pubDecl}struct $name${genericDecl}$boundsDecl {',
        indentBlock(br(fields.map((m) => m.code), ',\n')),
        '}'
      ]);

  // end <class Struct>

  Struct(dynamic id) : super(id);
}

class StructInst extends Object with GenericInst {
  Struct struct;

  // custom <class StructInst>

  StructInst(this.struct);

  String get name => struct.name;

  // end <class StructInst>

}

/// Tuple struct
class TupleStruct extends RsEntity
    with IsPub, Derives, Generic
    implements HasCode {
  // custom <class TupleStruct>

  Iterable<RsEntity> get children => genericChildren;

  String get code => brCompact([
        tripleSlashComment(doc?.toString() ?? 'TODO: Comment TupleStruct($id)'),
        '${pubDecl}struct $name$boundsDecl {',
        '}',
      ]);

  GenericInst inst(
          {Iterable typeArgs = const [], Iterable lifetimes = const []}) =>
      new TupleStructInst(this)
        ..typeArgs = typeArgs
        ..lifetimes = lifetimes;

  String get name => id.capCamel;

  // end <class TupleStruct>

  TupleStruct(dynamic id) : super(id);
}

class TupleStructInst extends Object with GenericInst {
  TupleStruct tupleStruct;

  // custom <class TupleStructInst>

  String get name => tupleStruct.name;

  TupleStructInst(this.tupleStruct);

  // end <class TupleStructInst>

}

/// Unit struct
class UnitStruct extends RsEntity with IsPub, Derives implements HasCode {
  // custom <class UnitStruct>

  Iterable<RsEntity> get children => new Iterable.empty();

  String get code => brCompact([
        tripleSlashComment(doc?.toString() ?? 'TODO: Comment UnitStruct($id)'),
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
TupleStruct pubTstruct(dynamic id) => new TupleStruct(id)..isPublic = true;

// end <library struct>
