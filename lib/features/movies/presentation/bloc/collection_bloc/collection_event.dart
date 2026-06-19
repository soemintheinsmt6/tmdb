import 'package:equatable/equatable.dart';

abstract class CollectionEvent extends Equatable {
  const CollectionEvent();

  @override
  List<Object?> get props => [];
}

class CollectionFetched extends CollectionEvent {
  const CollectionFetched(this.collectionId);
  final int collectionId;

  @override
  List<Object?> get props => [collectionId];
}
