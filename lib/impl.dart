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

  /// If true makes all functions `isUnitTestable`
  bool unitTestFunctions = false;

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
    functions.where((fn) => unitTestFunctions || fn.isUnitTestable).forEach(
        (fn) => unitTestModule.functions
            .add(makeUnitTestFunction(fn.id, 'test ${fn.codeBlock.tag}')));
  }

  @override
  Iterable<RsEntity> get children =>
      concat([new List<Fn>.from(functions, growable: false), genericChildren]);

  bool get hasUnitTestModule => _unitTestModule != null;

  // end <class Impl>

  /// Internal module for unit testing impl
  Module _unitTestModule;
}

class TraitImpl extends Impl with HasTypeAliases {
  /// Trait being implemented for a type
  TraitInst get trait => _trait;

  /// Type this implementation is for
  RsType get type => _type;

  // custom <class TraitImpl>

  TraitImpl(this._trait, this._type)
      : super(
            makeRsId(_trait.id.snake + '_' + makeGenericId(_type.code).snake)) {
    functions = _trait.functions
        .map((fn) => fn.copy()
          ..codeBlock = new CodeBlock('fn ${id.snake}_${fn.id.snake}'))
        .toList();

    codeBlock = new CodeBlock('impl ${_trait.name} for $_type');
  }

  @override
  onChildrenOwnershipEstablished() {
    super.onChildrenOwnershipEstablished();
    // Trait functions have been copied into impl Now find all instances of any
    // type args of TraitInst that match any type parms of the trait and replace
    // them.
    final replaceFromTo = enumerate(_trait.typeArgs).fold({},
        (prev, iv) => prev..[_trait.typeParms[iv.index].toString()] = iv.value);

    functions.forEach((fn) {
      final replacedParms = <Parm>[];
      enumerate(fn.parms).forEach((parmIndexValue) {
        final parm = parmIndexValue.value;
        final parmType = parm.type.toString();
        final found = replaceFromTo[parmType];
        if (found != null) {
          replacedParms.add(new Parm(parm.id, found));
        } else {
          replacedParms.add(parm);
        }
      });
      fn.parms = replacedParms;
    });
  }

  String get name => id.capCamel;

  GenericInst inst(
          {Iterable typeArgs = const [], Iterable lifetimes = const []}) =>
      throw 'TraitImpls are not instantiated in code';

  get unitTestableFunctions => functions.where((fn) => fn.isUnitTestable);

  @override
  String get code {
    return brCompact([
      !noComment
          ? tripleSlashComment(
              doc?.toString() ?? 'TODO: comment impl ${id.snake}')
          : null,
      '$_implHeader {',
      indentBlock(br([
        typeAliasDecls,
        functions.map((fn) => '${fn.code}'),
        codeBlock?.toString()
      ])),
      '}',
    ]);
  }

  get _implHeader => _trait == null
      ? 'impl$genericDecl ${_type}$boundsDecl'
      : 'impl$genericDecl ${_trait.genericName} for ${_type.lifetimeDecl}$boundsDecl';

  // end <class TraitImpl>

  TraitInst _trait;
  RsType _type;
}

class TypeImpl extends Impl {
  RsType get type => _type;

  // custom <class TypeImpl>

  String get name => id.snake;

  TypeImpl(this._type) : super(makeGenericId(_type.code)) {
    codeBlock = new CodeBlock('impl $_type');
  }

  GenericInst inst(
          {Iterable typeArgs = const [], Iterable lifetimes = const []}) =>
      throw 'TypeImpls are not instantiated in code';

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
TraitImpl traitImpl(dynamic trait, dynamic type) => new TraitImpl(
    trait is TraitInst ? trait : new TraitInst(trait), rsType(type));

/// alias impl to traitImpl - most common type of impl if doing trait work
final impl = traitImpl;

/// Creates a type impl
///
/// *type* - The type this impl applies to
TypeImpl typeImpl(dynamic type) => new TypeImpl(rsType(type));

// end <library impl>
