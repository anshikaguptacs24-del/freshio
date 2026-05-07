import 'dart:convert';
import 'package:http/http.dart' as http;

class UnsplashService {
  // Your provided API key is already inserted here
  final String _apiKey = 'DsMVTtbuAFbvniOnEZPOl5FZNTVHpSiA-KZbpyuOFgI'; 

  Future<String?> getImageUrl(String query) async {
    try {
      // 1. Create the dynamic URL using the query and your API key
      // We add 'food' to the query to ensure more relevant results for Freshio
      final url = Uri.parse(
        'https://api.unsplash.com/search/photos?query=$query,food&client_id=$_apiKey&per_page=1',
      );

      // 2. Make the network request
      final response = await http.get(url);

      // 3. Parse the response
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Unsplash search returns a list of results
        if (data['results'] != null && data['results'].isNotEmpty) {
          // Return the 'small' image URL for better performance in the grid
          return data['results'][0]['urls']['small'];
        }
      } else {
        print('Unsplash API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Unsplash Connection Error: $e');
    }
    
    // Return null if the search fails so the UI can show the letter placeholder
    return null;
  }
}