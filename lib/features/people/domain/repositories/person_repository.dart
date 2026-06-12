import 'package:tmdb/core/utils/typedef.dart';
import 'package:tmdb/features/people/domain/entities/person.dart';

/// Repository abstraction the rest of the app depends on. Concrete
/// implementations live in the data layer.
abstract class PersonRepository {
  ResultFuture<Person> getPersonDetail(int id);
}
