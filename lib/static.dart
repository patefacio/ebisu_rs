/// Support for *const* definitions
library ebisu_rs.static;

import 'package:ebisu/ebisu.dart';
import 'package:ebisu_rs/attribute.dart';
import 'package:ebisu_rs/entity.dart';
import 'package:ebisu_rs/type.dart';

// custom <additional imports>
// end <additional imports>

/// Defines a rust constant
class Static extends RsEntity with IsPub, HasAttributes {
  /// Value assigned to static
  dynamic value;

  /// Type associated with static
  RsType get type => _type;

  // custom <class Static>

  Static(dynamic id, [dynamic type])
      : _type = rsType(type),
        super(id);

  set type(dynamic type) => _type = rsType(type);

  String get code => brCompact([
        !noComment
            ? tripleSlashComment(doc?.toString() ??
                'TODO: comment static`${id.shout}`')
            : null,
        '${pubDecl}static ${id.shout}: ${type.code} = $value;'
      ]);

  // end <class Static>

  RsType _type;
}

abstract class HasStatics {
  List<Static> statics = [];

  // custom <class HasStatics>

  bool get hasStatics => statics.isNotEmpty;

  String get staticDecls => br(statics.map((s) => s.code));

  // end <class HasStatics>

}

// custom <library static>

Static static(dynamic id, [dynamic type]) => new Static(id, type);

Static pubStatic(dynamic id, [dynamic type]) =>
    new Static(id, type)..isPub = true;

// end <library static>
