library ebisu_rs.common_traits;

import 'package:ebisu_rs/trait.dart';
import 'package:id/id.dart';

// custom <additional imports>
// end <additional imports>

class BinaryOpTrait {
  Trait get trait => _trait;
  String get binarySymbol => _binarySymbol;

  // custom <class BinaryOpTrait>

  BinaryOpTrait(String traitName, this._binarySymbol) {
    final id = new Id(traitName);
    _trait = new Trait(id.capCamel)
      ..doc = 'Trait for binary operator `${id.capCamel}`.'
      ..typeParms = [#r_h_s]
      ..associatedTypes = [associatedType(#Output)]
      ..functions = [
        fn(id.snake,
            [self, parm(#rhs, 'RHS')..doc = 'Right hand side of binary op'])
          ..returns = 'Self::Output'
          ..returnDoc = '`Self::Output` result from binary operation'
          ..doc = 'Binary operation for (`self` `$binarySymbol` `rhs`).'
      ];
  }

  get name => _trait.unqualifiedName;

  // end <class BinaryOpTrait>

  Trait _trait;
  String _binarySymbol;
}

// custom <library common_traits>

final BinaryOpTrait addTrait = new BinaryOpTrait('add', '+');
final BinaryOpTrait subTrait = new BinaryOpTrait('sub', '-');
final BinaryOpTrait mulTrait = new BinaryOpTrait('mul', '*');
final BinaryOpTrait divTrait = new BinaryOpTrait('div', '/');
final BinaryOpTrait remTrait = new BinaryOpTrait('rem', '%');

final binaryOpTraits = [addTrait, subTrait, mulTrait, divTrait, remTrait];

final Trait derefTrait = trait('deref')
  ..associatedTypes = [#t]
  ..functions = [
    fn(#deref)
      ..doc = 'Method to dereference a value.'
      ..parms = [selfRef]
      ..returns = '&Self::Target'
      ..returnDoc = 'The dereferenced value'
  ];

final Trait derefMutTrait = trait('deref_mut')
  ..associatedTypes = [#t]
  ..functions = [
    fn(#deref_mut)
      ..doc = 'Method to dereference a value mutably (like *v = 1;).'
      ..parms = [selfRefMutable]
      ..returns = '&mut Self::Target'
      ..returnDoc = 'The dereferenced value'
  ];

final Trait defaultTrait = trait('default')
  ..functions = [
    fn('default')
      ..doc = 'A trait for giving a type a useful default value.'
      ..returns = 'Self'
      ..returnDoc = 'The default value for the type'
  ];

final Trait debugTrait = trait('debug')
  ..doc = 'Format trait for the ? character.'
  ..functions = [
    fn('fmt', [
      selfRef,
      parm('f', mref('Formatter'))..doc = '`Formatter` to format into'
    ])
      ..doc = 'Formats the value using the given formatter.'
      ..returns = '::std::result::Result<(), Error>'
      ..returnDoc = 'Unit or an error'
  ];

// end <library common_traits>
