import '../../domain/entities/sortie_entity.dart';

class SortieModel extends SortieEntity {
  const SortieModel({
    required super.nomProjet,
    required super.montant,
    required super.message,
    required super.date,
  });

  factory SortieModel.fromJson(Map<String, dynamic> json) {
    return SortieModel(
      nomProjet: json['nomProjet'] ?? '',
      montant: json['montant'] ?? 0,
      message: json['message'] ?? '',
      date: json['date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nomProjet': nomProjet,
      'montant': montant,
      'message': message,
      'date': date,
    };
  }
}
