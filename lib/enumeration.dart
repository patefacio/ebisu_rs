/// Library for enums
library ebisu_rs.enumeration;

import 'package:ebisu/ebisu.dart';
import 'package:ebisu_rs/entity.dart';

// custom <additional imports>
// end <additional imports>

class Variant extends RsEntity implements HasCode {
  // custom <class Variant>

  @override
  get children => new Iterable.empty();

  String get name => id.camel;

  @override
  String get code => name;

  // end <class Variant>

  Variant(dynamic id) : super(id);
}

class Enum extends RsEntity implements HasCode {
  List<Variant> get variants => _variants;

  /// If self includes *use self::<name>::*;
  bool get useSelf => _useSelf;

  // custom <class Enum>

  String get name => id.capCamel;

  void set variants(Iterable<dynamic> variants) =>
    _variants = variants.map(makeVariant).toList();

  Variant makeVariant(dynamic variant) => variant is String?
    new Variant(variant) : variant as Variant;

  @override
  String get code => brCompact([
        'enum $name {',
        indent(brCompact(variants.map((v) => v.code))),
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

Enum enum_(dynamic id, List<dynamic> variants) =>
  new Enum(id)..variants = variants;

// end <library enumeration>
