library ebisu_rs.attribute;

import 'package:ebisu_rs/entity.dart';
import 'package:id/id.dart';

// custom <additional imports>
// end <additional imports>

abstract class Attr {
  // custom <class Attr>

  String get attr;

  // end <class Attr>

}

class IdAttr extends Attr {
  /// Value of attribute
  Id value;

  // custom <class IdAttr>

  IdAttr(dynamic value) : value = makeRsId(value);

  @override
  String get attr => '[$value]';

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
  get attr => '[${key.snake}=$value]';

  // end <class KeyValueAttr>

}

class And extends Attr {
  List<Attr> attrs = [];

  // custom <class And>

  And(this.attrs);

  get attr => '[and(${attrs.map((a) => a.attr)})]';

  // end <class And>

}

// custom <library attribute>

Attr attr(dynamic key, String value) => new KeyValueAttr(key, value);
Attr idAttr(dynamic id) => new IdAttr(id);
Attr and(Iterable<Attr> attrs) => new And(attrs);

// end <library attribute>
