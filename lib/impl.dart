library ebisu_rs.impl;

import 'package:ebisu/ebisu.dart' hide codeBlock;
import 'package:ebisu_rs/entity.dart';
import 'package:ebisu_rs/trait.dart';

export 'package:ebisu_rs/entity.dart';
export 'package:ebisu_rs/trait.dart';

// custom <additional imports>
// end <additional imports>

class Impl extends RsEntity
    with HasCode, Generic, HasTypeAliases, HasCodeBlock {
  Trait get trait => _trait;
  RsType get type => _type;
  List<Fn> functions = [];

  // custom <class Impl>

  Impl(this._trait, this._type)
      : super(_trait == null
            ? makeGenericId(_type.code)
            : makeRsId(
                _trait.id.snake + '_' + makeGenericId(_type.code).snake)) {
    if (_trait != null) {
      functions = _trait.functions
          .map((fn) => fn.copy()
            ..codeBlock = new CodeBlock(id.snake + '_' + fn.id.snake))
          .toList();

      codeBlock = new CodeBlock('impl ${_trait.name} for $_type');
    }
  }

  Iterable<Entity> get children =>
      new List<Fn>.from(functions, growable: false);

  @override
  String get code => brCompact([
        tripleSlashComment(doc?.toString() ?? 'TODO: comment impl ${id.snake}'),
        '$_implHeader {',
        indentBlock(br([
          typeAliasDecls,
          functions.map((fn) => fn.code),
          codeBlock?.toString()
        ])),
        '}',
      ]);

  get _implHeader => _trait == null
      ? 'impl$genericDecl ${_type}'
      : 'impl$genericDecl ${_trait.name} for ${_type.code}';

  // end <class Impl>

  Trait _trait;
  RsType _type;
}

// custom <library impl>

Impl impl(Trait trait, RsType type) => new Impl(trait, type);

// end <library impl>
