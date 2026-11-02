import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.token,
    required super.nom,
    required super.prenom,
    required super.pseudo,
    required super.email,
    required super.motdepasse,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      token: json['token'] ?? '',
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      pseudo: json['pseudo'] ?? '',
      email: json['email'] ?? '',
      motdepasse: json['motdepasse'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'token': token,
      'nom': nom,
      'prenom': prenom,
      'pseudo': pseudo,
      'email': email,
      'motdepasse': motdepasse,
    };
  }
}
