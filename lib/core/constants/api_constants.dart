class ApiConstants {
  static const String baseUrl = 'http://192.168.42.69:8080/';

  // Auth endpoints
  static const String login = 'api/auth/login';
  static const String register = 'api/auth/register';
  static const String syncData = 'api/auth/sync';

  // Feature endpoints
  static const String solde = 'solde';
  static const String getEntree = 'getEntree';
  static const String addEntree = 'addEntree';
  static const String getProjets = 'getProjets';
  static const String createProjet = 'createProjet';
  static const String getSortie = 'getSortie';
  static String getProjetSorties(int idProjet) => 'getProjet/$idProjet';
  static String addSortie(int idProjet) => 'addSortie/$idProjet';
  static const String nbProjet = 'nbProjet';
}
