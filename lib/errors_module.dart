/// Models an errors module with customErrors for consistent error handling [See failure](https://boats.gitlab.io/failure/custom-fail.html)
library ebisu_rs.errors_module;

import 'package:ebisu/ebisu.dart';
import 'package:ebisu_rs/entity.dart';
import 'package:ebisu_rs/module.dart';
import 'package:id/id.dart';
import 'package:logging/logging.dart';

// custom <additional imports>
// end <additional imports>

final Logger _logger = new Logger('errors_module');

/// Models a single field in a [FailVariant] style _struct variant_
class FailField extends Field {
  /// If true, marks the field in the variant as the cause of the error
  bool isCause;

  // custom <class FailField>

  FailField(id, rsType, {isCause: false})
      : isCause = isCause,
        super(id, rsType);

  @override
  onOwnershipEstablished() {
    if (isCause) {
      attrs.add(idAttr('cause'));
    }
    super.onOwnershipEstablished();
  }

  // end <class FailField>

}

/// Models a single _struct variant_ in an enum defined by [CustomError]
class FailVariant extends StructVariant {
  /// Display string for the variant
  String display;

  /// List of fields to capture for the failure
  List<FailField> failFields = [];

  // custom <class FailVariant>

  FailVariant(id, {display: null, failFields: const []})
      : display = display,
        failFields = failFields,
        super(id);

  @override
  onOwnershipEstablished() {
    fields.addAll(failFields);
    attrs.add(strAttr('fail(display = ${display ?? '"TODO: need display"'})'));
    super.onOwnershipEstablished();
  }

  // end <class FailVariant>

}

/// Provides a custom error enumeration for use with *failure* crate
class CustomErrorEnum extends Enum {
  /// List of fail variants comprising the error
  List<FailVariant> failVariants = [];

  // custom <class CustomErrorEnum>

  CustomErrorEnum(id, {failVariants: const []})
      : failVariants = failVariants,
        super(id) {
    derive = [Fail, Debug];
    isPub = true;
  }

  @override
  onOwnershipEstablished() {
    if (failVariants.any((fv) => fv == null)) {
      throw new Exception("Display must be set for all variants");
    }
    ;
    variants.addAll(failVariants);
    super.onOwnershipEstablished();
  }

  get definition => code;

  // end <class CustomErrorEnum>

}

/// Models the module where custom errors are defined
class ErrorsModule extends Module {
  /// List of modeled custom errors
  List<CustomErrorEnum> customErrors = [];

  // custom <class ErrorsModule>

  ErrorsModule([this.customErrors]) : super('errors', fileModule) {
    isPub = true;
    doc = 'Provide for consistent errors using failure';
    pubUse('errors::*');
  }

  @override
  onOwnershipEstablished() {
    _logger.info('Ownership established for _error module_ ${owner?.id}:$id');
    enums.addAll(customErrors);
    super.onOwnershipEstablished();
  }

  // end <class ErrorsModule>

}

// custom <library errors_module>

CustomErrorEnum customErrorEnum(id, {failVariants: const []}) =>
    new CustomErrorEnum(id, failVariants: failVariants);

FailVariant failVariant(id, {display: null, failFields: const []}) =>
    new FailVariant(id, display: display, failFields: failFields);

FailField failField(id, rsType, {isCause: false}) =>
    new FailField(id, rsType, isCause: isCause);

// end <library errors_module>
