import '../entities/projet_entity.dart';

abstract class ProjetRepository {
  Future<List<ProjetEntity>> getProjets();
  Future<dynamic> createProjet(String nomProjet);
}
