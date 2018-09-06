library ebisu_rs.impl;

import 'package:ebisu/ebisu.dart' hide codeBlock;
import 'package:ebisu_rs/entity.dart';
import 'package:ebisu_rs/module.dart';
import 'package:ebisu_rs/trait.dart';
import 'package:logging/logging.dart';

export 'package:ebisu_rs/entity.dart';
export 'package:ebisu_rs/trait.dart';

// custom <additional imports>
import 'package:ebisu_rs/common_traits.dart';
// end <additional imports>

final Logger _logger = new Logger('impl');

abstract class Impl extends RsEntity
    with HasCode, Generic, HasCodeBlock, HasFunctions {
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
          ..withModuleCodeBlock(moduleTop, (cb) => null));
  }

  withUnitTestModule(void f(Module unitTestModule)) => f(unitTestModule);

  @override
  onChildrenOwnershipEstablished() {
    _logger.info('Ownership of Impl base ${id} established');
    functions
        .where((fn) =>
            (unitTestFunctions && fn.isUnitTestable != false) ||
            fn.isUnitTestable)
        .forEach((fn) {
      unitTestModule.functions
          .add(makeUnitTestFunction(fn.id, 'test ${fn.codeBlock.tag}'));
    });
  }

/** TODO Remove/Cleanup
  @override
  onChildrenOwnershipEstablished() {
    _logger.info('Ownership of Impl base ${id} established');
    functions.where((fn) => unitTestFunctions || fn.isUnitTestable).forEach(
        (fn) => unitTestModule.functions.add(
            makeUnitTestFunction(fn.id, 'test ${fn.codeBlock.tag}')
              ..codeBlock.snippets.add(customBlock(dottedPathToModule))));
  }
  */

  @override
  Iterable<RsEntity> get children =>
      concat([new List<Fn>.from(functions, growable: false), genericChildren]);

  @override
  String get unqualifiedName => id.capCamel;

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

  TraitImpl(this._trait, this._type, [bool nameGenerically = false])
      : super(makeRsId(_trait.id.snake +
            '_' +
            (nameGenerically
                ? makeGenericId(_type.typeName).snake
                : makeNonGenericId(_type.typeName).snake))) {
    functions = _trait.functions
        .map<Fn>((Fn fn) => fn.copy()
          ..codeBlock = new CodeBlock('fn ${id.snake}_${fn.id.snake}'))
        .toList();

    codeBlock = new CodeBlock('impl ${id.snake}');
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
          // TODO: Consider making parm copyable
          replacedParms.add(new Parm(parm.id, found)
            ..doc = parm.doc
            ..isMutable = parm.isMutable);
        } else {
          replacedParms.add(parm);
        }
      });
      fn.parms = replacedParms;
    });
  }

  @override
  GenericInst inst(
          {Iterable typeArgs = const [], Iterable lifetimes = const []}) =>
      throw 'TraitImpls are not instantiated in code';

  get unitTestableFunctions => functions.where((fn) => fn.isUnitTestable);

  @override
  String get code {
    return brCompact([
      !noComment
          ? tripleSlashComment(doc?.toString() ??
              'Implementation of trait `${trait.name}` for type `${type.typeName}`')
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

  TypeImpl(this._type, [bool nameGenerically = false])
      : super(nameGenerically
            ? makeGenericId(_type.typeName)
            : makeNonGenericId(_type.typeName)) {
    codeBlock = new CodeBlock('impl ${id.snake}');
  }

  GenericInst inst(
          {Iterable typeArgs = const [], Iterable lifetimes = const []}) =>
      throw 'TypeImpls are not instantiated in code';

  @override
  onOwnershipEstablished() {
    _logger.info("Ownership of impl ${id}:${runtimeType}");

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
            ? tripleSlashComment(doc?.toString() ??
                'Implementation for type `$unqualifiedName`.')
            : null,
        '$_implHeader {',
        indentBlock(
            br([functions.map((fn) => fn.code), codeBlock?.toString()])),
        '}',
      ]);

  get _implHeader => 'impl$genericDecl ${_type.lifetimeDecl}$boundsDecl';

  // end <class TypeImpl>

  RsType _type;
}

// custom <library impl>

/// Creates a trait impl
///
/// *trait* - The trait being implemented
///
/// *type* - The type this impl applies to
TraitImpl traitImpl(dynamic trait, dynamic type,
        [bool nameGenerically = false]) =>
    new TraitImpl(trait is TraitInst ? trait : new TraitInst(trait),
        rsType(type), nameGenerically);

/// alias impl to traitImpl - most common type of impl if doing trait work
final impl = traitImpl;

/// Creates a type impl
///
/// *type* - The type this impl applies to
TypeImpl typeImpl(dynamic type, [bool nameGenerically = false]) =>
    new TypeImpl(rsType(type), nameGenerically);

Impl addableImpl(Struct s) {
  final t = "& 'a ${s.unqualifiedName}";
  final result = traitImpl(addTrait.trait, new UnmodeledType(t))
    ..typeAliases = [typeAlias('output', s.unqualifiedName)]
    ..functions.first.codeBlock.snippets.add(brCompact([
          '${s.unqualifiedName} {',
          s.fields.map((f) =>
              'self.${f.id.snake} = self.${f.id.snake} + rhs.${f.id.snake}'),
          '}'
        ]));

  return result;
}

// end <library impl>
