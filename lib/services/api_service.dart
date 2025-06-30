import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../constants/app_constants.dart';

class ApiService {
  static Future<List<User>> fetchUsuarios() async {
    try {
      final url = Uri.parse(
        '${AppConstants.apiBaseUrl}${AppConstants.usuariosEndpoint}',
      );
      final response = await http
          .get(url)
          .timeout(AppConstants.timeoutDuration);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        throw Exception('Serviço não encontrado');
      } else if (response.statusCode >= 500) {
        throw Exception('Erro interno do servidor');
      } else {
        throw Exception('Erro na requisição: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('timeout')) {
        throw Exception('Tempo limite excedido. Verifique sua conexão.');
      } else if (e.toString().contains('SocketException')) {
        throw Exception('Sem conexão com a internet');
      } else {
        rethrow;
      }
    }
  }

  // Método para compatibilidade com código otimizado
  Future<List<User>> fetchUsers() async {
    return fetchUsuarios();
  }
}
