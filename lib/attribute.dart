library ebisu_rs.attribute;

import 'package:ebisu_rs/entity.dart';
import 'package:id/id.dart';

// custom <additional imports>
// end <additional imports>

abstract class Attr {
  // custom <class Attr>

  String get attr;

  String get internalAttr => '#![$attr]';
  String get externalAttr => '#[$attr]';

  // end <class Attr>

}

class IdAttr extends Attr {
  /// Value of attribute
  Id value;

  // custom <class IdAttr>

  IdAttr(dynamic value) : value = makeRsId(value);

  @override
  String get attr => '$value';

  // end <class IdAttr>

}

class KeyValueAttr extends Attr {
  /// Key if form is key/value
  Id key;

  /// Value of attribute
  String value;

  // custom <class KeyValueAttr>

  KeyValueAttr(dynamic key, this.value) : key = makeRsId(key);

  @override
  get attr => '${key.snake}=$value';

  // end <class KeyValueAttr>

}

class And extends Attr {
  List<Attr> attrs = [];

  // custom <class And>

  And(this.attrs);

  get attr => 'and(${attrs.map((a) => a.attr).join(", ")})';

  // end <class And>

}

abstract class HasAttributes {
  List<Attr> attrs = [];

  // custom <class HasAttributes>

  String get internalAttrs => attrs.map((attr) => attr.internalAttr).join('\n');
  String get externalAttrs => attrs.map((attr) => attr.externalAttr).join('\n');

  // end <class HasAttributes>

}

// custom <library attribute>

Attr attr(dynamic key, String value) => new KeyValueAttr(key, value);
Attr idAttr(dynamic id) => new IdAttr(id);
Attr and(Iterable<Attr> attrs) => new And(attrs);

// end <library attribute>
