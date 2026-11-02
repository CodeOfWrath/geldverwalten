import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/solde_model.dart';

abstract class SoldeRemoteDataSource {
  Future<List<SoldeModel>> getSolde();
}

class SoldeRemoteDataSourceImpl implements SoldeRemoteDataSource {
  final http.Client client;

  SoldeRemoteDataSourceImpl({required this.client});

  @override
  Future<List<SoldeModel>> getSolde() async {
    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.solde}'),
      headers: {
        'content-type': 'application/json',
        'Accept': '*/*',
        'Access-Control-Allow-Origin': '*'
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<SoldeModel> result = [];
      if (data is List) {
        for (var item in data) {
          result.add(SoldeModel.fromJson(item));
        }
      } else if (data is Map<String, dynamic>) {
        result.add(SoldeModel.fromJson(data));
      }
      return result;
    } else {
      throw ServerException('Échec du chargement du solde: ${response.statusCode}');
    }
  }
}
