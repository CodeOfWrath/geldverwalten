import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.nom,
    required super.prenom,
    required super.pseudo,
    required super.email,
    required super.token,
    super.isGuest = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      pseudo: json['pseudo'] ?? '',
      email: json['email'] ?? '',
      token: json['token'] ?? '',
      isGuest: json['isGuest'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'pseudo': pseudo,
      'email': email,
      'token': token,
      'isGuest': isGuest,
    };
  }
}
