import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/projet_model.dart';

abstract class ProjetRemoteDataSource {
  Future<List<ProjetModel>> getProjets();
  Future<dynamic> createProjet(String nomProjet);
}

class ProjetRemoteDataSourceImpl implements ProjetRemoteDataSource {
  final http.Client client;

  ProjetRemoteDataSourceImpl({required this.client});

  @override
  Future<List<ProjetModel>> getProjets() async {
    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.getProjets}'),
      headers: {
        'content-type': 'application/json',
        'Accept': '*/*',
        'Access-Control-Allow-Origin': '*'
      },
    ).timeout(const Duration(milliseconds: 800));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => ProjetModel.fromJson(item)).toList();
    } else {
      throw ServerException('Échec du chargement des projets');
    }
  }

  @override
  Future<dynamic> createProjet(String nomProjet) async {
    final data = {'nomProjet': nomProjet};

    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.createProjet}'),
      headers: {
        'content-type': 'application/json',
        'Accept': '*/*',
        'Access-Control-Allow-Origin': '*'
      },
      body: jsonEncode(data),
    ).timeout(const Duration(milliseconds: 800));

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw ServerException('Échec de la création du projet');
    }
  }
}
