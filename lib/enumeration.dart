/// Library for enums
library ebisu_rs.enumeration;

import 'package:ebisu/ebisu.dart';
import 'package:ebisu_rs/entity.dart';
import 'package:ebisu_rs/field.dart';
import 'package:ebisu_rs/type.dart';

// custom <additional imports>
// end <additional imports>

abstract class Variant extends RsEntity implements HasCode {
  // custom <class Variant>

  @override
  get children => new Iterable.empty();

  String get name => id.camel;

  // end <class Variant>

  Variant(dynamic id) : super(id);
}

class UnitVariant extends Variant {
  dynamic value;

  // custom <class UnitVariant>

  UnitVariant(dynamic id, [this.value]) : super(id);

  @override
  String get code => id.capCamel;

  // end <class UnitVariant>

}

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

class TupleVariant extends Variant implements HasCode {
  List<TupleField> get fields => _fields;

  // custom <class TupleVariant>

  TupleVariant(dynamic id, [Iterable fields]) : super(id) {
    this.fields = fields;
  }

  set fields(Iterable fields) => _fields = fields.map(makeField).toList();

  @override
  String get code => brCompact([
        '${id.capCamel}(',
        indentBlock(br(fields.map((f) => f.code), ',\n')),
        ')',
      ]);

  static TupleField makeField(dynamic f) => f is TupleField
      ? f
      : f is RsType
          ? new TupleField(f)
          : f is String
              ? new TupleField(new UserDefinedType(f))
              : throw 'makeField requires RsType or String -> ${f.runtimeType}';

  // end <class TupleVariant>

  List<TupleField> _fields = [];
}

class StructVariant extends Variant {
  List<Field> fields = [];

  // custom <class StructVariant>

  StructVariant(dynamic id) : super(id);

  @override
  String get code => id.camel;

  // end <class StructVariant>

}

class Enum extends RsEntity implements HasCode {
  List<Variant> get variants => _variants;

  /// If self includes *use self::<name>::*;
  bool get useSelf => _useSelf;

  // custom <class Enum>

  String get name => id.capCamel;

  void set variants(Iterable<Variant> variants) =>
      _variants = new List<Variant>.from(variants);

  @override
  String get code => brCompact([
        'enum $name {',
        indent(br(variants.map((v) => v.code), ',\n')),
        '}',
      ]);

  @override
  Iterable<RsEntity> get children => variants;

  // end <class Enum>

  Enum(dynamic id) : super(id);

  List<Variant> _variants = [];
  bool _useSelf = false;
}

// custom <library enumeration>

Enum enum_(dynamic id, List<dynamic> variants) => new Enum(id)
  ..variants = variants.map((v) => v is String ? uv(v) : v as Variant);

UnitVariant uv(dynamic id, [dynamic value]) => new UnitVariant(id, value);
TupleVariant tv(dynamic id, [Iterable fields]) => new TupleVariant(id, fields);

TupleField tf(dynamic type, [String doc]) => new TupleField(type, doc);

// end <library enumeration>
