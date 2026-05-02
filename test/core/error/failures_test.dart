import 'package:flutter_test/flutter_test.dart';
import 'package:tmdb/core/error/failures.dart';

void main() {
  group('ServerFailure', () {
    test('two with the same fields are equal', () {
      const a = ServerFailure(message: 'boom', statusCode: 500);
      const b = ServerFailure(message: 'boom', statusCode: 500);

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('different message → not equal', () {
      const a = ServerFailure(message: 'a', statusCode: 500);
      const b = ServerFailure(message: 'b', statusCode: 500);

      expect(a, isNot(equals(b)));
    });

    test('different statusCode → not equal', () {
      const a = ServerFailure(message: 'x', statusCode: 500);
      const b = ServerFailure(message: 'x', statusCode: 401);

      expect(a, isNot(equals(b)));
    });

    test('toString includes runtimeType, statusCode, and message', () {
      const failure = ServerFailure(message: 'boom', statusCode: 500);

      expect(failure.toString(), 'ServerFailure(500): boom');
    });
  });

  group('NetworkFailure', () {
    test('always reports statusCode 0', () {
      const failure = NetworkFailure(message: 'offline');

      expect(failure.statusCode, 0);
    });

    test('toString reflects the type and message', () {
      const failure = NetworkFailure(message: 'offline');

      expect(failure.toString(), 'NetworkFailure(0): offline');
    });

    test('different message → not equal', () {
      const a = NetworkFailure(message: 'a');
      const b = NetworkFailure(message: 'b');

      expect(a, isNot(equals(b)));
    });
  });

  test('ServerFailure and NetworkFailure are not equal even when fields align',
      () {
    const server = ServerFailure(message: 'x', statusCode: 0);
    const network = NetworkFailure(message: 'x');

    expect(server, isNot(equals(network)));
  });
}
