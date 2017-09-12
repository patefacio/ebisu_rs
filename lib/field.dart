library ebisu_rs.field;

import 'package:ebisu/ebisu.dart';
import 'package:ebisu_rs/attribute.dart';
import 'package:ebisu_rs/entity.dart';
import 'package:ebisu_rs/type.dart';
import 'package:logging/logging.dart';

// custom <additional imports>
// end <additional imports>

final Logger _logger = new Logger('field');

class Field extends RsEntity with IsPub, HasAttributes implements HasCode {
  /// Type of the field
  RsType get type => _type;

  // custom <class Field>

  Field(dynamic id, [dynamic type])
      : _type = type == null ? string : rsType(type),
        super(id);

  get children => new Iterable.empty();

  onOwnershipEstablished() {
    _logger.info("Ownership of ${id}:${runtimeType}");
  }

  set type(dynamic type) =>
      _type = type is String ? _type = new UnmodeledType(type) : type as RsType;

  String toString() => 'field($name:$type)';

  String get name => id.snake;

  String get code => brCompact([
        tripleSlashComment(doc?.toString() ?? 'TODO: comment field'),
        externalAttrs,
        '$pubDecl$name: ${type.lifetimeDecl}',
      ]);

  Iterable<Lifetime> get lifetimes => type.lifetimes;

  // end <class Field>

  RsType _type = string;
}

/// A field with type but no name, whose access is indexed
class TupleField implements HasCode {
  RsType type;
  String doc;

  // custom <class TupleField>

  TupleField(type, [this.doc]) : this.type = rsType(type);

  @override
  String get code => brCompact(
      [tripleSlashComment(doc == null ? 'TODO: comment' : doc), type]);

  // end <class TupleField>

}

// custom <library field>

/// Create a *Field*
///
/// id - Id of field
///
/// type - RsType-convertible type of field
Field field(dynamic id, [dynamic type]) => new Field(id, type);

/// Create a public *Field*
///
/// id - Id of field
///
/// type - RsType-convertable type of field
Field pubField(dynamic id, [dynamic type]) => new Field(id, type)..isPub = true;

// end <library field>
