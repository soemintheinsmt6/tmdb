import 'package:equatable/equatable.dart';
import 'package:tmdb/features/people/domain/entities/person.dart';

abstract class PersonDetailState extends Equatable {
  const PersonDetailState();

  @override
  List<Object?> get props => [];
}

class PersonDetailInitial extends PersonDetailState {
  const PersonDetailInitial();
}

class PersonDetailLoading extends PersonDetailState {
  const PersonDetailLoading();
}

class PersonDetailLoaded extends PersonDetailState {
  const PersonDetailLoaded({required this.person});
  final Person person;

  @override
  List<Object?> get props => [person];
}

class PersonDetailError extends PersonDetailState {
  const PersonDetailError({required this.message});
  final String message;

  @override
  List<Object?> get props => [message];
}
