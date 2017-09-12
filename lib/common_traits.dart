library ebisu_rs.common_traits;

import 'package:ebisu_rs/trait.dart';
import 'package:id/id.dart';

// custom <additional imports>
// end <additional imports>

// custom <library common_traits>

_numBinaryOpTrait(tag) {
  final id = new Id(tag);
  return trait(id.capCamel)
    ..associatedTypes = [associatedType(#Output)]
    ..functions = [
      fn(id.snake, [self, parm(#rhs, 'RHS')])..returns = 'Self::Output'
    ];
}

final Trait addTrait = _numBinaryOpTrait('add');
final Trait subTrait = _numBinaryOpTrait('sub');
final Trait mulTrait = _numBinaryOpTrait('mul');
final Trait divTrait = _numBinaryOpTrait('div');
final Trait remTrait = _numBinaryOpTrait('rem');

final Trait derefTrait = _numBinaryOpTrait('deref');
final Trait derefMutTrait = _numBinaryOpTrait('deref_mut');

// end <library common_traits>
