library ebisu_rs.impl;

import 'package:ebisu/ebisu.dart';
import 'package:ebisu_rs/entity.dart';
import 'package:ebisu_rs/trait.dart';

export 'package:ebisu_rs/trait.dart';

// custom <additional imports>
// end <additional imports>

class Impl extends RsEntity with HasCode, HasTypeAliases {
  Trait get trait => _trait;
  RsType get type => _type;

  // custom <class Impl>

  Impl(this._trait, this._type)
      : super(_trait == null
            ? makeGenericId(_type.code)
            : makeRsId(
                _trait.id.snake + '_' + makeGenericId(_type.code).snake));

  @override
  String get code => brCompact([
        '$_implHeader {',
        _trait != null ? _trait.functions.map((fn) => fn.signature) : null,
        '}',
      ]);

  get _implHeader => _trait == null
      ? 'impl ${_type}'
      : 'impl ${_trait.name} for ${_type.code}';

  // end <class Impl>

  Trait _trait;
  RsType _type;
}

// custom <library impl>

Impl impl(Trait trait, RsType type) => new Impl(trait, type);

// end <library impl>
