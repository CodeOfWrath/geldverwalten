import 'package:flutter_test/flutter_test.dart';
import 'package:geldverwalten/features/balance/domain/entities/solde_entity.dart';
import 'package:geldverwalten/features/balance/domain/repositories/solde_repository.dart';
import 'package:geldverwalten/features/balance/domain/usecases/get_solde.dart';

class MockSoldeRepository implements SoldeRepository {
  @override
  Future<List<SoldeEntity>> getSolde() async {
    return const [SoldeEntity(montant: 215500)];
  }
}

void main() {
  late GetSolde usecase;
  late MockSoldeRepository mockRepository;

  setUp(() {
    mockRepository = MockSoldeRepository();
    usecase = GetSolde(mockRepository);
  });

  test('should return list of SoldeEntity from the repository', () async {
    final result = await usecase();

    expect(result, isA<List<SoldeEntity>>());
    expect(result.first.montant, 215500);
  });
}
