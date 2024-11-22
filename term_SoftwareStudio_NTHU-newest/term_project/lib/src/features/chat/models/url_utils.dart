// url_utils.dart
import 'package:term_project/src/features/chat/models/url_utils.dart'; // Utility to detect URLs

bool isImageUrl(String url) {
  final imageExtensions = ['jpg', 'jpeg', 'png', 'gif'];
  return imageExtensions.any((ext) => url.toLowerCase().endsWith('.$ext'));
}

List<String> extractUrls(String text) {
  final urlPattern = RegExp(
    r'((https?:\/\/)?([\w-]+(\.[\w-]+)+\.?(:\d+)?(\/\S*)?)|(www\.[\w-]+(\.[\w-]+)+(\S*)?))',
    caseSensitive: false,
  );
  return urlPattern.allMatches(text).map((match) => match.group(0)!).toList();
}
