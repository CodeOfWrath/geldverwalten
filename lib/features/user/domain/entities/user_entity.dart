class UserEntity {
  final int id;
  final String nom;
  final String prenom;
  final String pseudo;
  final String email;
  final String motdepasse;
  final String token;

  const UserEntity({
    required this.id,
    required this.token,
    required this.nom,
    required this.prenom,
    required this.pseudo,
    required this.email,
    required this.motdepasse,
  });
}
