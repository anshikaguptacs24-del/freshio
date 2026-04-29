import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:freshio/data/models/item.dart';

class DonationHelper {
  static Future<void> openDonationLink(BuildContext context, Item item) async {
    final query = "food donation near me";
    final url = Uri.parse("https://www.google.com/maps/search/${Uri.encodeComponent(query)}");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening nearby donation options for ${item.name}... 🌍'),
        backgroundColor: Colors.teal,
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open maps. Please check your browser.')),
      );
    }
  }

  static List<Map<String, String>> getNGOs() {
    return [
      {"name": "Feeding India", "url": "https://www.feedingindia.org/"},
      {"name": "Robin Hood Army", "url": "https://robinhoodarmy.com/"},
      {"name": "No Kid Hungry", "url": "https://www.nokidhungry.org/"},
    ];
  }

  static Future<void> openNGO(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
