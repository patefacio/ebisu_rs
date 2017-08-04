library ebisu_rs.dependency;

import 'package:logging/logging.dart';

// custom <additional imports>
// end <additional imports>

final Logger _logger = new Logger('dependency');

enum CompareOp { gt, lt, ge, le, eq, tilda, caret }

/// Convenient access to CompareOp.gt with *gt* see [CompareOp].
///
const CompareOp gt = CompareOp.gt;

/// Convenient access to CompareOp.lt with *lt* see [CompareOp].
///
const CompareOp lt = CompareOp.lt;

/// Convenient access to CompareOp.ge with *ge* see [CompareOp].
///
const CompareOp ge = CompareOp.ge;

/// Convenient access to CompareOp.le with *le* see [CompareOp].
///
const CompareOp le = CompareOp.le;

/// Convenient access to CompareOp.eq with *eq* see [CompareOp].
///
const CompareOp eq = CompareOp.eq;

/// Convenient access to CompareOp.tilda with *tilda* see [CompareOp].
///
const CompareOp tilda = CompareOp.tilda;

/// Convenient access to CompareOp.caret with *caret* see [CompareOp].
///
const CompareOp caret = CompareOp.caret;

/// Models a [*Semantic Versioning*](http://semver.org/) version
class Version {
  int major;
  int minor;
  int patch;

  // custom <class Version>

  Version([this.major = 0, this.minor = 0, this.patch = 0]);

  static RegExp _versionStringRe =
      new RegExp(r'(\d+)(?:\.(\d+))?(?:\.(\d+))?$');

  Version.fromString(String versionString) {
    final match = _versionStringRe.firstMatch(versionString);
    if (match != null) {
      major = int.parse(match.group(1));
      final minorStr = match.group(2);
      minor = minorStr == null ? null : int.parse(minorStr);
      final patchStr = match.group(3);
      patch = patchStr == null ? null : int.parse(patchStr);
    }
  }

  toString() {
    final List<int> parts = [];
    if (major != null) parts.add(major);
    if (minor != null) parts.add(minor);
    if (patch != null) parts.add(patch);
    return parts.join('.');
  }

  // end <class Version>

}

/// Models single constriant in *VersionSpec*
class VersionConstraint {
  CompareOp compareOp;
  Version version;

  // custom <class VersionConstraint>

  VersionConstraint(dynamic compareOp, dynamic version) {
    this.compareOp = compareOp is String
        ? _compareOpFromString(compareOp)
        : compareOp as CompareOp;
    this.version = version is String
        ? new Version.fromString(version)
        : version as Version;
  }

  String toString() => '${compareOpToString(compareOp)}$version';

  static CompareOp _compareOpFromString(String op) {
    CompareOp resolved;
    switch (op) {
      case '<':
        {
          resolved = lt;
          break;
        }
      case '>':
        {
          resolved = gt;
          break;
        }
      case '<=':
        {
          resolved = le;
          break;
        }
      case '>=':
        {
          resolved = ge;
          break;
        }
      case '=':
        {
          resolved = eq;
          break;
        }
      case '~':
        {
          resolved = tilda;
          break;
        }
      case '^':
        {
          resolved = caret;
          break;
        }
    }

    return resolved;
  }

  // end <class VersionConstraint>

}

/// Models a crate verion spec (eg containing caret, constraints)
class VersionSpec {
  List<VersionConstraint> constraints = [];

  // custom <class VersionSpec>

  VersionSpec(this.constraints);

  VersionSpec.fromString(String spec) {
    final darkSpec = spec.replaceAll(_anyWhiteSpace, '');

    for (final constraint in darkSpec.split(',')) {
      final match =
          _specRe.firstMatch(constraint.replaceAll(_anyWhiteSpace, ''));
      final compareOp = VersionConstraint._compareOpFromString(match.group(1));
      constraints.add(new VersionConstraint(
          compareOp, new Version.fromString(match.group(2))));
    }
  }

  toString() => constraints.join(', ');

  final RegExp _anyWhiteSpace = new RegExp(r'\s+');
  static RegExp _specRe = new RegExp(r'^([~<>^]?=?)(\d+(?:\.\d+){0,2})$');

  // end <class VersionSpec>

}

class Dependency {
  String crate;
  VersionSpec get version => _version;
  String path;
  bool isBuildDependency = false;

  // custom <class Dependency>

  Dependency(this.crate, dynamic version) {
    this.version = version;
  }

  set version(dynamic versionSpec) => _version = versionSpec is String
      ? new VersionSpec.fromString(versionSpec)
      : versionSpec as VersionSpec;

  String get _decl =>
      path != null ? '{ version = "$version", path = "$path" }' : '"$version"';

  toString() => '${crate} = $_decl';

  // end <class Dependency>

  VersionSpec _version;
}

// custom <library dependency>

Dependency dependency(String crate, dynamic version) =>
    new Dependency(crate, version);

String compareOpToString(CompareOp compareOp) {
  if (compareOp == null) return '';
  switch (compareOp) {
    case lt:
      return '<';
    case gt:
      return '>';
    case le:
      return '<=';
    case ge:
      return '>=';
    case eq:
      return '=';
    case tilda:
      return '~';
    case caret:
      return '^';
  }
  return 'Unrecognized CompareOp($compareOp)';
}

// end <library dependency>
