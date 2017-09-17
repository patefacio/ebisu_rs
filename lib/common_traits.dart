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
    ..doc = 'Trait for binary operator `${id.capCamel}`'
    ..typeParms = [#r_h_s]
    ..associatedTypes = [associatedType(#Output)]
    ..functions = [
      fn(id.snake, [self, parm(#rhs, 'RHS')..doc = 'right hand side of binary op'])
        ..returns = 'Self::Output'
        ..returnDoc = '`Self::Output` result from binary operation'
        ..doc = 'Binary operation for (`self` `$binarySymbol` `rhs`)'
    ];
  }

  get name => _trait.name;


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

final Trait derefTrait = _numBinaryOpTrait('deref');
final Trait derefMutTrait = _numBinaryOpTrait('deref_mut');

// end <library common_traits>
