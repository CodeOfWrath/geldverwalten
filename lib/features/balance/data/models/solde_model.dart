import '../../domain/entities/solde_entity.dart';

class SoldeModel extends SoldeEntity {
  const SoldeModel({required super.montant});

  factory SoldeModel.fromJson(Map<String, dynamic> json) {
    return SoldeModel(
      montant: json['montant'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'montant': montant,
    };
  }
}
