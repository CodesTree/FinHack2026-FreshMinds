import '../config/app_env.dart';
import '../models/user_model.dart';
import 'api_client.dart';

class SurvivaiRepository {
  SurvivaiRepository({ApiClient? apiClient, String? apiBaseUrl})
      : _apiClient = apiClient ?? ApiClient(),
        _apiBaseUrl = apiBaseUrl ?? AppEnv.apiBaseUrl;

  final ApiClient _apiClient;
  final String _apiBaseUrl;

  Future<UserModel> fetchSurvivalScore(String userId) async {
    final uri = Uri.parse('$_apiBaseUrl/survival-score?user_id=$userId');
    final body = await _apiClient.getJson(uri);
    return UserModel.fromApi(body);
  }
}
