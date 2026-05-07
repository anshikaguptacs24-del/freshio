import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_keys.dart';

class UnsplashService {
  Future<String?> getImageUrl(String query) async {
    final url = Uri.parse(
      '${ApiConstants.unsplashBaseUrl}/search/photos?query=$query&client_id=${ApiConstants.unsplashAccessKey}&per_page=1'
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'].isNotEmpty) {
          // Use 'small' or 'thumb' to save data and load faster
          return data['results'][0]['urls']['small'];
        }
      }
    } catch (e) {
      print("Error fetching image: $e");
    }
    return null; 
  }
}