import '../../domain/entities/projet_entity.dart';

class ProjetModel extends ProjetEntity {
  const ProjetModel({
    required super.id,
    required super.idUser,
    required super.statut,
    required super.nomProjet,
    super.montantCible = 100000,
    super.montantActuel = 68000,
  });

  factory ProjetModel.fromJson(Map<String, dynamic> json) {
    return ProjetModel(
      id: json['id'] ?? 0,
      idUser: json['idUser'] ?? 0,
      statut: json['statut'] ?? 0,
      nomProjet: json['nomProjet'] ?? '',
      montantCible: json['montantCible'] ?? 100000,
      montantActuel: json['montantActuel'] ?? 68000,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idUser': idUser,
      'statut': statut,
      'nomProjet': nomProjet,
      'montantCible': montantCible,
      'montantActuel': montantActuel,
    };
  }
}
