library ebisu_rs.generic;

import 'package:ebisu_rs/entity.dart';
import 'package:id/id.dart';
import 'package:quiver/iterables.dart';

// custom <additional imports>
// end <additional imports>

class Lifetime extends RsEntity {
  Id id;

  // custom <class Lifetime>
  get children => new Iterable.empty();
  // end <class Lifetime>

  Lifetime(dynamic id) : super(id);
}

class TypeParm extends RsEntity {
  Id id;

  // custom <class TypeParm>

  get children => new Iterable.empty();

  // end <class TypeParm>

  TypeParm(dynamic id) : super(id);
}

class Generic {
  List<Lifetime> lifetimes = [];
  List<TypeParm> typeParms = [];

  // custom <class Generic>

  get children =>
      new List<RsEntity>.from(concat([lifetimes, typeParms]), growable: false);

  // end <class Generic>

}

// custom <library generic>
// end <library generic>
