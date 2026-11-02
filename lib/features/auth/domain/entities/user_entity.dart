class UserEntity {
  final int id;
  final String nom;
  final String prenom;
  final String pseudo;
  final String email;
  final String token;
  final bool isGuest;

  const UserEntity({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.pseudo,
    required this.email,
    required this.token,
    this.isGuest = false,
  });

  static const UserEntity guest = UserEntity(
    id: 0,
    nom: "Invité",
    prenom: "Utilisateur",
    pseudo: "Micaelle",
    email: "invite@depensia.cm",
    token: "",
    isGuest: true,
  );
}
