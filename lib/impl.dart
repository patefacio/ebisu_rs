library ebisu_rs.impl;

import 'package:ebisu/ebisu.dart' hide codeBlock;
import 'package:ebisu_rs/entity.dart';
import 'package:ebisu_rs/module.dart';
import 'package:ebisu_rs/trait.dart';
import 'package:logging/logging.dart';

export 'package:ebisu_rs/entity.dart';
export 'package:ebisu_rs/trait.dart';

// custom <additional imports>
// end <additional imports>

final Logger _logger = new Logger('impl');

abstract class Impl extends RsEntity with HasCode, Generic, HasCodeBlock {
  List<Fn> functions = [];

  // custom <class Impl>

  Impl(dynamic id) : super(id);

  Module get unitTestModule {
    _logger.info(
        'Initializing unitTestModule $id -> $_unitTestModule $hasUnitTestModule');
    return _unitTestModule ??
        (_unitTestModule = module(id, inlineModule)
          ..uses = ['super::*']
          ..noComment = true
          ..withModuleCodeBlock(moduleBottom, (cb) => null));
  }

  withUnitTestModule(void f(Module unitTestModule)) => f(unitTestModule);

  @override
  onOwnershipEstablished() {
    _logger.info('Ownership of Impl base ${id} established');
    functions.where((fn) => fn.isUnitTestable).forEach((fn) => unitTestModule
        .functions
        .add(makeUnitTestFunction(fn.id, 'test ${fn.codeBlock.tag}')));
  }

  @override
  Iterable<Entity> get children =>
      new List<Fn>.from(functions, growable: false);

  bool get hasUnitTestModule => _unitTestModule != null;

  // end <class Impl>

  /// Internal module for unit testing impl
  Module _unitTestModule;
}

class TraitImpl extends Impl with HasTypeAliases {
  Trait get trait => _trait;
  RsType get type => _type;

  // custom <class TraitImpl>

  TraitImpl(this._trait, this._type)
      : super(_trait == null
            ? makeGenericId(_type.code)
            : makeRsId(
                _trait.id.snake + '_' + makeGenericId(_type.code).snake)) {
    functions = _trait.functions
        .map((fn) => fn.copy()
          ..codeBlock = new CodeBlock('fn ${id.snake}_${fn.id.snake}'))
        .toList();

    codeBlock = new CodeBlock('impl ${_trait.name} for $_type');
  }

  get unitTestableFunctions => functions.where((fn) => fn.isUnitTestable);

  @override
  String get code => brCompact([
        !noComment
            ? tripleSlashComment(
                doc?.toString() ?? 'TODO: comment impl ${id.snake}')
            : null,
        '$_implHeader {',
        indentBlock(br([
          typeAliasDecls,
          functions.map((fn) => fn.code),
          codeBlock?.toString()
        ])),
        '}',
      ]);

  get _implHeader => _trait == null
      ? 'impl$genericDecl ${_type}$boundsDecl'
      : 'impl$genericDecl ${_trait.name} for ${_type.code}$boundsDecl';

  // end <class TraitImpl>

  Trait _trait;
  RsType _type;
}

class TypeImpl extends Impl {
  RsType get type => _type;

  // custom <class TypeImpl>

  TypeImpl(this._type) : super(makeGenericId(_type.code)) {
    codeBlock = new CodeBlock('impl $_type');
  }

  @override
  onOwnershipEstablished() {
    /// Go through functions and tag custom block with type
    /// This helps prevent custom block tag duplicates
    functions.forEach((fn) {
      final cbTag = fn.codeBlock.tag;
      if (cbTag == 'fn ${fn.id.snake}') {
        fn.codeBlock.tag = 'fn ${id.snake}_${fn.id.snake}';
      }
    });
  }

  @override
  String get code => brCompact([
        !noComment
            ? tripleSlashComment(
                doc?.toString() ?? 'TODO: comment impl ${id.snake}')
            : null,
        '$_implHeader {',
        indentBlock(
            br([functions.map((fn) => fn.code), codeBlock?.toString()])),
        '}',
      ]);

  get _implHeader => 'impl$genericDecl ${_type}$boundsDecl';

  // end <class TypeImpl>

  RsType _type;
}

// custom <library impl>

/// Creates a trait impl
///
/// *trait* - The trait being implemented
///
/// *type* - The type this impl applies to
TraitImpl traitImpl(Trait trait, dynamic type) =>
    new TraitImpl(trait, rsType(type));

/// alias impl to traitImpl - most common type of impl if doing trait work
final impl = traitImpl;

/// Creates a type impl
///
/// *type* - The type this impl applies to
TypeImpl typeImpl(dynamic type) => new TypeImpl(rsType(type));

// end <library impl>
