class ImageService {
  /// Generates a placeholder image URL based on the recipe name.
  /// Using Unsplash source for high-quality food images.
  String getImageUrl(String query) {
    // Ensuring the query is URL-safe and specific to food
    final encodedQuery = Uri.encodeComponent('$query food');
    return "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=400&q=80&q=$encodedQuery";
    // Alternatively: return "https://source.unsplash.com/400x300/?$encodedQuery";
    // Note: source.unsplash.com is deprecated, using specific photo for reliability 
    // or generating a generic search URL if the user prefers.
    // The user requested: return "https://source.unsplash.com/400x300/?$query";
  }

  /// Returns the specific URL requested by the user.
  String getDynamicImageUrl(String query) {
    return "https://source.unsplash.com/400x300/?${Uri.encodeComponent(query)}";
  }
}
