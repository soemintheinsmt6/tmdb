import 'package:dartz/dartz.dart';
import 'package:tmdb/core/error/failures.dart';

/// A [Future] that returns either a [Failure] or a value of type [T].
typedef ResultFuture<T> = Future<Either<Failure, T>>;

/// A future that yields either a [Failure] or void.
typedef ResultVoid = ResultFuture<void>;

/// Shorthand for a JSON map.
typedef DataMap = Map<String, dynamic>;
