library ebisu_rs.struct;

import 'package:ebisu/ebisu.dart';
import 'package:ebisu_rs/entity.dart';
import 'package:ebisu_rs/field.dart';
import 'package:ebisu_rs/generic.dart';
import 'package:ebisu_rs/macro.dart';
import 'package:logging/logging.dart';
import 'package:quiver/iterables.dart';

// custom <additional imports>

export 'package:ebisu_rs/field.dart';

// end <additional imports>

final Logger _logger = new Logger('struct');

class Struct extends RsEntity with IsPub, Derives, Generic implements HasCode {
  List<Field> fields = [];

  // custom <class Struct>

  get children => new List<Field>.from(fields, growable: false);

  String toString() => 'struct($name)';

  String get name => id.capCamel;

  @override
  onOwnershipEstablished() {
    _logger.info("Ownership of struct ${id}:${runtimeType}");
    for (final field in fields) {
      if (field.type.isRef) {}
    }
  }

  Iterable<String> get lifetimes => new Set<String>.from(concat(
          fields.map<Iterable<String>>((m) => m.lifetimes.map((lt) => "'$lt"))))
      .toList()
        ..sort();

  String get template {
    var contents = chomp(brCompact([
      lifetimes.join(', '),
    ]));
    return contents.isNotEmpty ? '<$contents>' : '';
  }

  String get code => brCompact([
        tripleSlashComment(doc?.toString() ?? 'TODO: comment struct'),
        derives,
        '${pubDecl}struct $name${template} {',
        indentBlock(br(fields.map((m) => m.code), ',\n')),
        '}'
      ]);

  // end <class Struct>

  Struct(dynamic id) : super(id);
}

/// Tuple struct
class TupleStruct extends RsEntity
    with IsPub, Derives, Generic
    implements HasCode {
  // custom <class TupleStruct>

  Iterable<Entity> get children => new Iterable.empty();

  String get code => brCompact([
        tripleSlashComment(doc?.toString() ?? 'TODO: Comment TupleStruct($id)'),
        'struct $name {',
        '}',
      ]);

  String get name => id.capCamel;

  // end <class TupleStruct>

  TupleStruct(dynamic id) : super(id);
}

/// Unit struct
class UnitStruct extends RsEntity with IsPub, Derives implements HasCode {
  // custom <class UnitStruct>

  Iterable<Entity> get children => new Iterable.empty();

  String get code => brCompact([
        tripleSlashComment(doc?.toString() ?? 'TODO: Comment UnitStruct($id)'),
        'struct $name;'
      ]);

  String get name => id.capCamel;

  // end <class UnitStruct>

  UnitStruct(dynamic id) : super(id);
}

// custom <library struct>

Struct struct(dynamic id) => new Struct(id);

UnitStruct ustruct(dynamic id) => new UnitStruct(id);

TupleStruct tstruct(dynamic id) => new TupleStruct(id);

// end <library struct>
