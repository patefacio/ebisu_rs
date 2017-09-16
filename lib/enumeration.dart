/// Library for enums
library ebisu_rs.enumeration;

import 'package:ebisu/ebisu.dart';
import 'package:ebisu_rs/entity.dart';
import 'package:ebisu_rs/field.dart';
import 'package:ebisu_rs/macro.dart';
import 'package:ebisu_rs/type.dart';

export 'package:ebisu_rs/field.dart';
export 'package:ebisu_rs/macro.dart';
export 'package:ebisu_rs/type.dart';

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
  String get code => brCompact([
        tripleSlashComment(doc == null ? 'TODO: comment $id' : doc),
        value != null ? '${id.capCamel} = $value' : id.capCamel
      ]);

  // end <class UnitVariant>

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
              ? new TupleField(new UnmodeledType(f))
              : throw 'makeField requires RsType or String -> ${f.runtimeType}';

  // end <class TupleVariant>

  List<TupleField> _fields = [];
}

class StructVariant extends Variant {
  List<Field> get fields => _fields;

  // custom <class StructVariant>

  StructVariant(dynamic id, [Iterable fields]) : super(id) {
    this.fields = fields;
  }

  set fields(Iterable fields) =>
      _fields = fields.map((f) => f is Field ? f : field(f)).toList();

  @override
  String get code => brCompact([
        tripleSlashComment(doc == null ? 'TODO: comment $id' : doc),
        '${id.capCamel}{',
        indentBlock(br(fields.map((f) => f.code), ',\n')),
        '}',
      ]);

  // end <class StructVariant>

  List<Field> _fields = [];
}

class Enum extends RsEntity with IsPub, Derives, Generic implements HasCode {
  List<Variant> get variants => _variants;

  /// If self includes *use self::<name>::*;
  bool useSelf = false;

  // custom <class Enum>

  String get name => id.capCamel;

  void set variants(Iterable<Variant> variants) =>
      _variants = new List<Variant>.from(variants);

  @override
  String get code => brCompact([
        tripleSlashComment(doc == null ? 'TODO: comment $id' : doc),
        derives,
        '${pubDecl}enum $name$genericDecl$boundsDecl {',
        indent(br(variants.map((v) => v.code), ',\n')),
        '}',
        useSelf ? 'use self::$name::*;' : null
      ]);

  @override
  toString() => 'enum($name)';

  @override
  Iterable<RsEntity> get children => variants;

  GenericInst inst(
          {Iterable typeArgs = const [], Iterable lifetimes = const []}) =>
      new EnumInst(this)
        ..typeArgs = typeArgs
        ..lifetimes = lifetimes;

  // end <class Enum>

  Enum(dynamic id) : super(id);

  List<Variant> _variants = [];
}

class EnumInst extends Object with GenericInst {
  Enum enumeration;

  // custom <class EnumInst>

  String get name => enumeration.name;

  EnumInst(this.enumeration);

  // end <class EnumInst>

}

// custom <library enumeration>

Enum enum_(dynamic id, Iterable<dynamic> variants) => new Enum(id)
  ..variants = variants.map((v) => v is String ? uv(v) : v as Variant);

UnitVariant uv(dynamic id, [dynamic value]) => new UnitVariant(id, value);
TupleVariant tv(dynamic id, [Iterable fields]) => new TupleVariant(id, fields);
TupleField tf(dynamic type, [String doc]) => new TupleField(type, doc);
StructVariant sv(dynamic id, [Iterable fields]) =>
    new StructVariant(id, fields);
// end <library enumeration>
