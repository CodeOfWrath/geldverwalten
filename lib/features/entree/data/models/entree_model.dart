import '../../domain/entities/entree_entity.dart';

class EntreeModel extends EntreeEntity {
  const EntreeModel({
    required super.montant,
    required super.origine,
    required super.date,
  });

  factory EntreeModel.fromJson(Map<String, dynamic> json) {
    return EntreeModel(
      montant: json['montant'] ?? 0,
      origine: json['message'] ?? '',
      date: json['date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'montant': montant,
      'message': origine,
      'date': date,
    };
  }
}
