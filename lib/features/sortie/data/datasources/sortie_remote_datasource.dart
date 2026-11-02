import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/sortie_model.dart';

abstract class SortieRemoteDataSource {
  Future<List<SortieModel>> getSorties();
  Future<List<SortieModel>> getSortiesByProjet(int idProjet);
  Future<dynamic> addSortie(String raison, String montant, int idProjet);
}

class SortieRemoteDataSourceImpl implements SortieRemoteDataSource {
  final http.Client client;

  SortieRemoteDataSourceImpl({required this.client});

  @override
  Future<List<SortieModel>> getSorties() async {
    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.getSortie}'),
      headers: {
        'content-type': 'application/json',
        'Accept': '*/*',
        'Access-Control-Allow-Origin': '*'
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => SortieModel.fromJson(item)).toList();
    } else {
      throw ServerException('Échec du chargement des sorties: ${response.statusCode}');
    }
  }

  @override
  Future<List<SortieModel>> getSortiesByProjet(int idProjet) async {
    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.getProjetSorties(idProjet)}'),
      headers: {
        'content-type': 'application/json',
        'Accept': '*/*',
        'Access-Control-Allow-Origin': '*'
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => SortieModel.fromJson(item)).toList();
    } else {
      throw ServerException('Échec du chargement des sorties du projet: ${response.statusCode}');
    }
  }

  @override
  Future<dynamic> addSortie(String raison, String montant, int idProjet) async {
    final data = {
      'montant': montant,
      'message': raison,
    };

    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.addSortie(idProjet)}'),
      headers: {
        'content-type': 'application/json',
        'Accept': '*/*',
        'Access-Control-Allow-Origin': '*'
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw ServerException('Échec de l\'ajout de la sortie: ${response.statusCode}');
    }
  }
}
