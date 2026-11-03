import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/entree_model.dart';

abstract class EntreeRemoteDataSource {
  Future<List<EntreeModel>> getEntrees();
  Future<dynamic> addEntree(String origine, int montant);
}

class EntreeRemoteDataSourceImpl implements EntreeRemoteDataSource {
  final http.Client client;

  EntreeRemoteDataSourceImpl({required this.client});

  @override
  Future<List<EntreeModel>> getEntrees() async {
    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.getEntree}'),
      headers: {
        'content-type': 'application/json',
        'Accept': '*/*',
        'Access-Control-Allow-Origin': '*'
      },
    ).timeout(const Duration(milliseconds: 800));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => EntreeModel.fromJson(item)).toList();
    } else {
      throw ServerException('Échec du chargement des entrées');
    }
  }

  @override
  Future<dynamic> addEntree(String origine, int montant) async {
    final data = {
      'montant': montant,
      'message': origine,
    };

    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.addEntree}'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode(data),
    ).timeout(const Duration(milliseconds: 800));

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw ServerException('Échec de l\'ajout de l\'entrée');
    }
  }
}
