import 'package:equatable/equatable.dart';

abstract class PersonDetailEvent extends Equatable {
  const PersonDetailEvent();

  @override
  List<Object?> get props => [];
}

class PersonDetailFetched extends PersonDetailEvent {
  const PersonDetailFetched(this.personId);
  final int personId;

  @override
  List<Object?> get props => [personId];
}
