library ebisu_rs.member;

import 'package:ebisu/ebisu.dart';
import 'package:ebisu_rs/entity.dart';
import 'package:ebisu_rs/type.dart';

// custom <additional imports>
// end <additional imports>

class Member extends RsEntity with IsPub implements HasCode {
  /// Type of the member
  RsType get type => _type;

  // custom <class Member>

  get children => new Iterable.empty();

  onOwnershipEstablished() {
    print("^^^^^^^^Ownership of ${id}:${runtimeType}");
  }

  set type(dynamic type) => _type =
      type is String ? _type = new UserDefinedType(type) : type as RsType;

  String toString() => 'member($name:$type)';

  String get name => id.snake;

  String get code => brCompact([
        tripleSlashComment(doc?.toString() ?? 'TODO: comment member'),
        '$pubDecl$name: ${type.scopedDecl},',
      ]);

  Iterable<String> get lifetimes => type.lifetimes;

  // end <class Member>

  Member(dynamic id) : super(id);

  RsType _type = string;
}

// custom <library member>
// end <library member>
