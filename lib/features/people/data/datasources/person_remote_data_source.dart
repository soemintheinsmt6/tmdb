import 'package:tmdb/core/constants/api_constants.dart';
import 'package:tmdb/core/network/api_client.dart';
import 'package:tmdb/features/people/domain/entities/person.dart';
import 'package:tmdb/features/people/domain/entities/person_credit.dart';

/// Network-only client for the people feature. Throws the exceptions defined
/// in `core/error/exceptions.dart`; the repository converts them to
/// `Failure`s.
class PersonRemoteDataSource {
  const PersonRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<Person> getPersonDetail(int id) async {
    final response = await _apiClient.get(
      ApiConstants.personDetail(id),
      query: {'language': 'en-US'},
    );
    return Person.fromJson(response as Map<String, dynamic>);
  }

  /// Parses the `cast` array of `/person/{id}/combined_credits`, drops entries
  /// that aren't a routable movie/TV title, collapses duplicates (a title can
  /// appear more than once), and orders by popularity so the most recognisable
  /// roles surface first.
  Future<List<PersonCredit>> getCombinedCredits(int id) async {
    final response = await _apiClient.get(
      ApiConstants.personCombinedCredits(id),
      query: {'language': 'en-US'},
    );
    final json = response as Map<String, dynamic>;

    final seen = <String>{};
    final credits = <PersonCredit>[];
    for (final raw in (json['cast'] as List?) ?? const []) {
      final credit = PersonCredit.fromJson(raw as Map<String, dynamic>);
      if (credit.mediaType == null) continue;
      if (!seen.add('${credit.mediaType!.name}:${credit.id}')) continue;
      credits.add(credit);
    }

    credits.sort((a, b) => b.popularity.compareTo(a.popularity));
    return credits;
  }
}
