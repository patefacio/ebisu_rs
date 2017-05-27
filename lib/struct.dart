library ebisu_rs.struct;

import 'package:ebisu/ebisu.dart';
import 'package:ebisu_rs/entity.dart';
import 'package:id/id.dart';

// custom <additional imports>
// end <additional imports>

class Member extends RsEntity {
  String type;

  // custom <class Member>
  // end <class Member>

  Member(id) : super(id);
}

class Struct extends RsEntity {
  /// Id for Struct
  Id id;
  List<Member> members = [];

  // custom <class Struct>
  // end <class Struct>

  Struct(id) : super(id);
}

// custom <library struct>

struct(id) => new Struct(id);

// end <library struct>
