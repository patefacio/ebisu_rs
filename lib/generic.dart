library ebisu_rs.generic;

import 'package:ebisu/ebisu.dart';
import 'package:ebisu_rs/entity.dart';
import 'package:id/id.dart';
import 'package:quiver/iterables.dart';

// custom <additional imports>
// end <additional imports>

class Lifetime extends RsEntity implements HasCode {
  // custom <class Lifetime>
  get children => new Iterable.empty();

  @override
  get code => "'${id.snake}";

  // end <class Lifetime>

  Lifetime(dynamic id) : super(id);
}

class TypeParm extends RsEntity implements HasCode {
  // custom <class TypeParm>

  get children => new Iterable.empty();

  @override
  get code => "${id.capCamel}";

  // end <class TypeParm>

  TypeParm(dynamic id) : super(id);
}

class Generic {
  List<Lifetime> get lifetimes => _lifetimes;
  List<TypeParm> get typeParms => _typeParms;

  // custom <class Generic>

  generic(Iterable<dynamic> lifetimes, Iterable<dynamic> typeParms) {
    _lifetimes =
        lifetimes.map((lt) => lt is Lifetime ? lt : lifetime(lt)).toList();
    _typeParms =
        typeParms.map((tp) => tp is TypeParm ? tp : typeParm(tp)).toList();

    print('lifetimes ${this.lifetimes}');
  }

  get children =>
      new List<RsEntity>.from(concat([lifetimes, typeParms]), growable: false);

  get genericDecl => [
        '<',
        concat([
          lifetimes.map((lt) => lt.code),
          typeParms.map((parm) => parm.code)
        ]).join(', '),
        '>'
      ].join('');

  // end <class Generic>

  List<Lifetime> _lifetimes = [];
  List<TypeParm> _typeParms = [];
}

// custom <library generic>

Lifetime lifetime(dynamic id) => new Lifetime(id);
TypeParm typeParm(dynamic id) => new TypeParm(id);

// end <library generic>
