library ebisu_rs.field;

import 'package:ebisu/ebisu.dart';
import 'package:ebisu_rs/attribute.dart';
import 'package:ebisu_rs/entity.dart';
import 'package:ebisu_rs/type.dart';
import 'package:logging/logging.dart';

// custom <additional imports>
// end <additional imports>

final Logger _logger = new Logger('field');

/// Defines accessors and visibility
enum Access {
  /// Field is private with a getter
  ro,

  /// Field is public
  rw,

  /// Field is private with no accessor
  ia,

  /// Field is private with a setter
  wo
}

/// Convenient access to Access.ro with *ro* see [Access].
///
/// Field is private with a getter
///
const Access ro = Access.ro;

/// Convenient access to Access.rw with *rw* see [Access].
///
/// Field is public
///
const Access rw = Access.rw;

/// Convenient access to Access.ia with *ia* see [Access].
///
/// Field is private with no accessor
///
const Access ia = Access.ia;

/// Convenient access to Access.wo with *wo* see [Access].
///
/// Field is private with a setter
///
const Access wo = Access.wo;

class Field extends RsEntity with IsPub, HasAttributes implements HasCode {
  /// Type of the field
  RsType get type => _type;

  /// Access for the field, only has impact if not-null
  Access get access => _access;

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

  set access(Access access) {
    _access = access;
    if (access == ro || access == wo || access == ia) {
      isPub = false;
    } else {
      isPub = true;
    }
  }

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
  Access _access;
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
