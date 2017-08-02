library ebisu_rs.field;

import 'package:ebisu/ebisu.dart';
import 'package:ebisu_rs/entity.dart';
import 'package:ebisu_rs/type.dart';

// custom <additional imports>
// end <additional imports>

class Field extends RsEntity with IsPub implements HasCode {
  /// Type of the field
  RsType get type => _type;

  // custom <class Field>

  get children => new Iterable.empty();

  onOwnershipEstablished() {
    print("^^^^^^^^Ownership of ${id}:${runtimeType}");
  }

  set type(dynamic type) => _type =
      type is String ? _type = new UserDefinedType(type) : type as RsType;

  String toString() => 'field($name:$type)';

  String get name => id.snake;

  String get code => brCompact([
        tripleSlashComment(doc?.toString() ?? 'TODO: comment field'),
        '$pubDecl$name: ${type.scopedDecl}',
      ]);

  Iterable<String> get lifetimes => type.lifetimes;

  // end <class Field>

  Field(dynamic id) : super(id);

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

Field field(dynamic id) => new Field(id);

// end <library field>
