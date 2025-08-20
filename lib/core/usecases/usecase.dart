import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';

/// Base class for all use cases in the application
/// 
/// This abstract class provides a consistent interface for all use cases
/// following the single responsibility principle.
abstract class UseCase<Type, Params> {
  /// Executes the use case with the given parameters
  /// 
  /// Returns [Either<Failure, Type>] where Type is the success result
  Future<Either<Failure, Type>> call(Params params);
}

/// Represents the absence of parameters for a use case
class NoParams {
  const NoParams();
}
