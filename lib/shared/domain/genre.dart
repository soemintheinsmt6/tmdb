import 'package:equatable/equatable.dart';

/// A TMDB genre, shared by the movie and TV features.
class Genre extends Equatable {
  const Genre({required this.id, required this.name});

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(id: json['id'] as int, name: json['name'] as String? ?? '');
  }

  final int id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}
