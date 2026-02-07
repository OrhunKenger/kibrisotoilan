import 'package:equatable/equatable.dart';

class BrandEntity extends Equatable {
  final int id;
  final String name;
  final String? logoUrl;

  const BrandEntity({
    required this.id,
    required this.name,
    this.logoUrl,
  });

  @override
  List<Object?> get props => [id, name, logoUrl];
}
