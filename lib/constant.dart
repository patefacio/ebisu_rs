/// Support for *const* definitions
library ebisu_rs.constant;

import 'package:ebisu/ebisu.dart';
import 'package:ebisu_rs/attribute.dart';
import 'package:ebisu_rs/entity.dart';
import 'package:ebisu_rs/type.dart';

// custom <additional imports>
// end <additional imports>

/// Defines a rust constant
class Const extends RsEntity with IsPub, HasAttributes {
  /// Value assigned to constant
  dynamic value;

  /// Type associated with constant
  RsType get type => _type;

  // custom <class Const>

  Const(dynamic id, [this._type]) : super(id);

  set type(dynamic type) => _type = rsType(type);

  String get code => brCompact([
        !noComment
            ? tripleSlashComment(doc?.toString() ??
                'TODO: comment static`${id.shout}`')
            : null,
        '${pubDecl}const ${id.shout}: ${type.code} = $value;'
      ]);


  // end <class Const>

  RsType _type;
}

abstract class HasConstants {
  List<Const> constants = [];

  // custom <class HasConstants>

  bool get hasConstants => constants.isNotEmpty;
  String get constantDecls => br(constants.map((c) => c.code));

  // end <class HasConstants>

}

// custom <library constant>

Const const_(dynamic id, [dynamic type]) => new Const(id, type);

Const pubConst(dynamic id, [dynamic type]) => new Const(id, type)..isPub = true;

// end <library constant>
