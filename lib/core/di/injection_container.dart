import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';

import '../../features/balance/data/datasources/solde_local_datasource.dart';
import '../../features/balance/data/datasources/solde_remote_datasource.dart';
import '../../features/balance/data/repositories/solde_repository_impl.dart';
import '../../features/balance/domain/repositories/solde_repository.dart';
import '../../features/balance/domain/usecases/get_solde.dart';

import '../../features/entree/data/datasources/entree_local_datasource.dart';
import '../../features/entree/data/datasources/entree_remote_datasource.dart';
import '../../features/entree/data/repositories/entree_repository_impl.dart';
import '../../features/entree/domain/repositories/entree_repository.dart';
import '../../features/entree/domain/usecases/add_entree.dart';
import '../../features/entree/domain/usecases/get_entrees.dart';

import '../../features/projet/data/datasources/projet_local_datasource.dart';
import '../../features/projet/data/datasources/projet_remote_datasource.dart';
import '../../features/projet/data/repositories/projet_repository_impl.dart';
import '../../features/projet/domain/repositories/projet_repository.dart';
import '../../features/projet/domain/usecases/create_projet.dart';
import '../../features/projet/domain/usecases/get_projets.dart';

import '../../features/sortie/data/datasources/sortie_local_datasource.dart';
import '../../features/sortie/data/datasources/sortie_remote_datasource.dart';
import '../../features/sortie/data/repositories/sortie_repository_impl.dart';
import '../../features/sortie/domain/repositories/sortie_repository.dart';
import '../../features/sortie/domain/usecases/add_sortie.dart';
import '../../features/sortie/domain/usecases/get_sorties.dart';
import '../../features/sortie/domain/usecases/get_sorties_by_projet.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  bool _isInitialized = false;

  late final http.Client httpClient;
  late final SharedPreferences sharedPreferences;

  // Auth
  late final AuthRemoteDataSource authRemoteDataSource;
  late final AuthLocalDataSource authLocalDataSource;
  late final AuthRepository authRepository;
  late final LoginUseCase loginUseCase;
  late final RegisterUseCase registerUseCase;
  late final GetCurrentUserUseCase getCurrentUserUseCase;
  late final LogoutUseCase logoutUseCase;

  // Solde
  late final SoldeRemoteDataSource soldeRemoteDataSource;
  late final SoldeLocalDataSource soldeLocalDataSource;
  late final SoldeRepository soldeRepository;
  late final GetSolde getSoldeUseCase;

  // Entree
  late final EntreeRemoteDataSource entreeRemoteDataSource;
  late final EntreeLocalDataSource entreeLocalDataSource;
  late final EntreeRepository entreeRepository;
  late final GetEntrees getEntreesUseCase;
  late final AddEntreeUseCase addEntreeUseCase;

  // Projet
  late final ProjetRemoteDataSource projetRemoteDataSource;
  late final ProjetLocalDataSource projetLocalDataSource;
  late final ProjetRepository projetRepository;
  late final GetProjets getProjetsUseCase;
  late final CreateProjetUseCase createProjetUseCase;

  // Sortie
  late final SortieRemoteDataSource sortieRemoteDataSource;
  late final SortieLocalDataSource sortieLocalDataSource;
  late final SortieRepository sortieRepository;
  late final GetSorties getSortiesUseCase;
  late final GetSortiesByProjet getSortiesByProjetUseCase;
  late final AddSortieUseCase addSortieUseCase;

  Future<void> init() async {
    if (_isInitialized) return;

    httpClient = http.Client();
    sharedPreferences = await SharedPreferences.getInstance();

    // Auth
    authRemoteDataSource = AuthRemoteDataSourceImpl(client: httpClient);
    authLocalDataSource = AuthLocalDataSourceImpl(sharedPreferences: sharedPreferences);
    authRepository = AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
      localDataSource: authLocalDataSource,
    );
    loginUseCase = LoginUseCase(authRepository);
    registerUseCase = RegisterUseCase(authRepository);
    getCurrentUserUseCase = GetCurrentUserUseCase(authRepository);
    logoutUseCase = LogoutUseCase(authRepository);

    // Solde
    soldeRemoteDataSource = SoldeRemoteDataSourceImpl(client: httpClient);
    soldeLocalDataSource = SoldeLocalDataSourceImpl(sharedPreferences: sharedPreferences);
    soldeRepository = SoldeRepositoryImpl(
      remoteDataSource: soldeRemoteDataSource,
      localDataSource: soldeLocalDataSource,
    );
    getSoldeUseCase = GetSolde(soldeRepository);

    // Entree
    entreeRemoteDataSource = EntreeRemoteDataSourceImpl(client: httpClient);
    entreeLocalDataSource = EntreeLocalDataSourceImpl(sharedPreferences: sharedPreferences);
    entreeRepository = EntreeRepositoryImpl(
      remoteDataSource: entreeRemoteDataSource,
      localDataSource: entreeLocalDataSource,
    );
    getEntreesUseCase = GetEntrees(entreeRepository);
    addEntreeUseCase = AddEntreeUseCase(entreeRepository);

    // Projet
    projetRemoteDataSource = ProjetRemoteDataSourceImpl(client: httpClient);
    projetLocalDataSource = ProjetLocalDataSourceImpl(sharedPreferences: sharedPreferences);
    projetRepository = ProjetRepositoryImpl(
      remoteDataSource: projetRemoteDataSource,
      localDataSource: projetLocalDataSource,
    );
    getProjetsUseCase = GetProjets(projetRepository);
    createProjetUseCase = CreateProjetUseCase(projetRepository);

    // Sortie
    sortieRemoteDataSource = SortieRemoteDataSourceImpl(client: httpClient);
    sortieLocalDataSource = SortieLocalDataSourceImpl(sharedPreferences: sharedPreferences);
    sortieRepository = SortieRepositoryImpl(
      remoteDataSource: sortieRemoteDataSource,
      localDataSource: sortieLocalDataSource,
    );
    getSortiesUseCase = GetSorties(sortieRepository);
    getSortiesByProjetUseCase = GetSortiesByProjet(sortieRepository);
    addSortieUseCase = AddSortieUseCase(sortieRepository);

    _isInitialized = true;
  }
}

final sl = ServiceLocator();
