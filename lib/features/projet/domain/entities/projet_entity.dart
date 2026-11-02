class ProjetEntity {
  final int id;
  final int idUser;
  final int statut;
  final String nomProjet;
  final int montantCible;
  final int montantActuel;

  const ProjetEntity({
    required this.id,
    required this.idUser,
    required this.statut,
    required this.nomProjet,
    this.montantCible = 100000,
    this.montantActuel = 68000,
  });

  double get progressPercentage {
    if (montantCible <= 0) return 0.0;
    final ratio = montantActuel / montantCible;
    return ratio > 1.0 ? 1.0 : ratio;
  }
}
