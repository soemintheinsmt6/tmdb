import 'package:equatable/equatable.dart';

/// Base failure class — returned via `Either<Failure, T>` in repositories.
abstract class Failure extends Equatable {
  const Failure({required this.message, required this.statusCode});

  final String message;
  final int statusCode;

  @override
  List<Object?> get props => [message, statusCode];

  @override
  String toString() => '$runtimeType($statusCode): $message';
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, required super.statusCode});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message}) : super(statusCode: 0);
}
