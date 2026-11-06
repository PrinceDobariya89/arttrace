import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/models/web_image_model.dart';

class WebImageService {
  final HttpClient _client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 10)
    ..badCertificateCallback = ((X509Certificate cert, String host, int port) => true);

  // Curated high quality web drawings & line-art references
  static const List<WebImageModel> curatedDrawings = [
    // Anime & Manga
    WebImageModel(
      id: 'web_anime_01',
      title: 'Anime Samurai Warrior',
      imageUrl: 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800&auto=format&fit=crop&q=80',
      category: 'Anime',
      source: 'Unsplash Art',
      tags: ['anime', 'samurai', 'japanese', 'warrior', 'manga'],
    ),
    WebImageModel(
      id: 'web_anime_02',
      title: 'Manga Girl Portrait Outline',
      imageUrl: 'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?w=800&auto=format&fit=crop&q=80',
      category: 'Anime',
      source: 'Unsplash Art',
      tags: ['anime', 'girl', 'portrait', 'face', 'manga'],
    ),
    WebImageModel(
      id: 'web_anime_03',
      title: 'Cyberpunk Ninja Lineart',
      imageUrl: 'https://images.unsplash.com/photo-1563089145-599997674d42?w=800&auto=format&fit=crop&q=80',
      category: 'Anime',
      source: 'Unsplash Art',
      tags: ['ninja', 'cyberpunk', 'mask', 'katana', 'anime'],
    ),

    // Animals & Wildlife
    WebImageModel(
      id: 'web_animal_01',
      title: 'Detailed Lion Head Sketch',
      imageUrl: 'https://images.unsplash.com/photo-1546182990-dffeafbe841d?w=800&auto=format&fit=crop&q=80',
      category: 'Animals',
      source: 'Wildlife Art',
      tags: ['lion', 'animal', 'wildlife', 'big cat', 'mane', 'sketch'],
    ),
    WebImageModel(
      id: 'web_animal_02',
      title: 'Geometric Wolf Line Art',
      imageUrl: 'https://images.unsplash.com/photo-1564349683136-77e08dba1ef6?w=800&auto=format&fit=crop&q=80',
      category: 'Animals',
      source: 'Modern Art',
      tags: ['wolf', 'geometric', 'tattoo', 'canine', 'wild'],
    ),
    WebImageModel(
      id: 'web_animal_03',
      title: 'Majestic Eagle in Flight',
      imageUrl: 'https://images.unsplash.com/photo-1516331138075-f3adc1e149cd?w=800&auto=format&fit=crop&q=80',
      category: 'Animals',
      source: 'Bird Art',
      tags: ['eagle', 'bird', 'wings', 'flight', 'raptor'],
    ),
    WebImageModel(
      id: 'web_animal_04',
      title: 'Cute Red Panda Outline',
      imageUrl: 'https://images.unsplash.com/photo-1543946207-39bd91e70ca7?w=800&auto=format&fit=crop&q=80',
      category: 'Animals',
      source: 'Nature Reference',
      tags: ['panda', 'cute', 'animal', 'baby', 'chibi'],
    ),

    // Flowers & Botanicals
    WebImageModel(
      id: 'web_flower_01',
      title: 'Vintage Botanical Rose',
      imageUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800&auto=format&fit=crop&q=80',
      category: 'Flowers',
      source: 'Botanical',
      tags: ['rose', 'flower', 'botanical', 'petals', 'floral', 'sketch'],
    ),
    WebImageModel(
      id: 'web_flower_02',
      title: 'Delicate Cherry Blossom Branch',
      imageUrl: 'https://images.unsplash.com/photo-1522383225653-ed111181a951?w=800&auto=format&fit=crop&q=80',
      category: 'Flowers',
      source: 'Flora Art',
      tags: ['cherry blossom', 'sakura', 'branch', 'spring', 'flowers'],
    ),
    WebImageModel(
      id: 'web_flower_03',
      title: 'Sunflowers in Bloom Contour',
      imageUrl: 'https://images.unsplash.com/photo-1597848212624-a19eb35e2651?w=800&auto=format&fit=crop&q=80',
      category: 'Flowers',
      source: 'Nature Art',
      tags: ['sunflower', 'summer', 'blooming', 'petals', 'flower'],
    ),

    // Tattoo & Flash Art
    WebImageModel(
      id: 'web_tattoo_01',
      title: 'Sacred Mandala Pattern',
      imageUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=800&auto=format&fit=crop&q=80',
      category: 'Tattoo',
      source: 'Tattoo Flash',
      tags: ['mandala', 'pattern', 'geometry', 'ornament', 'tattoo'],
    ),
    WebImageModel(
      id: 'web_tattoo_02',
      title: 'Traditional Dragon Silhouette',
      imageUrl: 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=800&auto=format&fit=crop&q=80',
      category: 'Tattoo',
      source: 'Tattoo Flash',
      tags: ['dragon', 'oriental', 'mythical', 'scales', 'tattoo'],
    ),
    WebImageModel(
      id: 'web_tattoo_03',
      title: 'Skull with Crown of Roses',
      imageUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800&auto=format&fit=crop&q=80',
      category: 'Tattoo',
      source: 'Flash Art',
      tags: ['skull', 'roses', 'gothic', 'tattoo', 'dark art'],
    ),

    // Cartoons & Chibi
    WebImageModel(
      id: 'web_cartoon_01',
      title: 'Cute Baby Dinosaur',
      imageUrl: 'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?w=800&auto=format&fit=crop&q=80',
      category: 'Cartoon',
      source: 'Illustration',
      tags: ['dinosaur', 'chibi', 'cute', 'cartoon', 'kids'],
    ),
    WebImageModel(
      id: 'web_cartoon_02',
      title: 'Whimsical Little Owl',
      imageUrl: 'https://images.unsplash.com/photo-1579783902614-a3fb3927b675?w=800&auto=format&fit=crop&q=80',
      category: 'Cartoon',
      source: 'Illustration',
      tags: ['owl', 'bird', 'cute', 'cartoon', 'chibi'],
    ),

    // Architecture & Vehicles
    WebImageModel(
      id: 'web_arch_01',
      title: 'Classic Sports Car Silhouette',
      imageUrl: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=800&auto=format&fit=crop&q=80',
      category: 'Vehicles',
      source: 'Auto Sketch',
      tags: ['car', 'porsche', 'sports car', 'vehicle', 'automotive'],
    ),
    WebImageModel(
      id: 'web_arch_02',
      title: 'Eiffel Tower Line Drawing',
      imageUrl: 'https://images.unsplash.com/photo-1511739001486-6bfe10ce785f?w=800&auto=format&fit=crop&q=80',
      category: 'Architecture',
      source: 'Travel Sketch',
      tags: ['eiffel tower', 'paris', 'monument', 'landmark', 'building'],
    ),
  ];

  // Search web images by query & optional category filter
  Future<List<WebImageModel>> searchWebImages({
    required String query,
    String? category,
  }) async {
    final cleanQuery = query.trim().toLowerCase();

    // 1. First, search and filter the curated library
    List<WebImageModel> results = [];
    if (category != null && category.isNotEmpty && category != 'All') {
      results = curatedDrawings.where((d) => d.category.toLowerCase() == category.toLowerCase()).toList();
    } else {
      results = List.from(curatedDrawings);
    }

    if (cleanQuery.isNotEmpty) {
      results = results.where((item) {
        final inTitle = item.title.toLowerCase().contains(cleanQuery);
        final inCategory = item.category.toLowerCase().contains(cleanQuery);
        final inTags = item.tags.any((t) => t.toLowerCase().contains(cleanQuery));
        return inTitle || inCategory || inTags;
      }).toList();
    }

    // 2. Query Wikimedia Commons open API for online drawings if online
    if (cleanQuery.isNotEmpty) {
      try {
        final onlineResults = await _queryWikimediaCommons(cleanQuery);
        if (onlineResults.isNotEmpty) {
          results.addAll(onlineResults);
        }
      } catch (e) {
        debugPrint('Web search API notice: $e');
      }
    }

    return results;
  }

  // Free, open-access image search via Wikimedia Commons
  Future<List<WebImageModel>> _queryWikimediaCommons(String query) async {
    try {
      final searchTerm = Uri.encodeComponent('$query drawing sketch line art');
      final uri = Uri.parse(
        'https://commons.wikimedia.org/w/api.php?action=query&generator=search&gsrsearch=$searchTerm&gsrnamespace=6&prop=imageinfo&iiprop=url|size|mime&format=json&origin=*',
      );

      final request = await _client.getUrl(uri);
      request.headers.set('User-Agent', 'ArtTrace-App/1.0 (contact@arttrace.internal)');
      final response = await request.close().timeout(const Duration(seconds: 4));

      if (response.statusCode != 200) return [];

      final body = await response.transform(utf8.decoder).join();
      final Map<String, dynamic> data = jsonDecode(body);

      final queryObj = data['query'] as Map<String, dynamic>?;
      if (queryObj == null) return [];

      final pages = queryObj['pages'] as Map<String, dynamic>?;
      if (pages == null) return [];

      final List<WebImageModel> list = [];
      for (final entry in pages.values) {
        final imageinfo = entry['imageinfo'] as List<dynamic>?;
        if (imageinfo != null && imageinfo.isNotEmpty) {
          final info = imageinfo.first as Map<String, dynamic>;
          final url = info['url'] as String?;
          final mime = info['mime'] as String? ?? '';
          if (url != null && (mime.contains('image/png') || mime.contains('image/jpeg') || mime.contains('image/webp'))) {
            final rawTitle = entry['title'] as String? ?? 'Web Drawing';
            final cleanTitle = rawTitle.replaceFirst('File:', '').replaceAll(RegExp(r'\.[a-zA-Z]{3,4}$'), '');
            list.add(
              WebImageModel(
                id: 'wiki_${entry['pageid']}',
                title: cleanTitle.length > 30 ? cleanTitle.substring(0, 30) : cleanTitle,
                imageUrl: url,
                thumbnailUrl: info['thumburl'] as String? ?? url,
                category: 'Web Search',
                source: 'Wikimedia Commons',
                tags: query.split(' '),
              ),
            );
          }
        }
        if (list.length >= 8) break;
      }
      return list;
    } catch (_) {
      return [];
    }
  }

  // Download image from URL and save locally in app storage
  Future<File> downloadAndCacheImage(String imageUrl) async {
    try {
      final uri = Uri.parse(imageUrl);
      final request = await _client.getUrl(uri);
      request.headers.set('User-Agent', 'ArtTrace-App/1.0');
      final response = await request.close().timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception('Server returned HTTP ${response.statusCode}');
      }

      final bytes = await consolidateHttpClientResponseBytes(response);

      // Determine directory
      final dir = await getApplicationDocumentsDirectory();
      final targetDir = Directory('${dir.path}/web_cache');
      if (!targetDir.existsSync()) {
        targetDir.createSync(recursive: true);
      }

      final ext = imageUrl.contains('.png')
          ? '.png'
          : (imageUrl.contains('.webp') ? '.webp' : '.jpg');
      final filename = 'trace_web_${DateTime.now().millisecondsSinceEpoch}$ext';
      final file = File('${targetDir.path}/$filename');
      await file.writeAsBytes(bytes);

      return file;
    } catch (e) {
      debugPrint('Error downloading web image: $e');
      rethrow;
    }
  }

  // Save base64 data URI image
  Future<File> saveBase64Image(String dataUri) async {
    try {
      final commaIndex = dataUri.indexOf(',');
      final base64Str = commaIndex != -1 ? dataUri.substring(commaIndex + 1) : dataUri;
      final bytes = base64Decode(base64Str);

      final dir = await getApplicationDocumentsDirectory();
      final targetDir = Directory('${dir.path}/web_cache');
      if (!targetDir.existsSync()) {
        targetDir.createSync(recursive: true);
      }

      final ext = dataUri.contains('image/png') ? '.png' : '.jpg';
      final filename = 'trace_google_${DateTime.now().millisecondsSinceEpoch}$ext';
      final file = File('${targetDir.path}/$filename');
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      debugPrint('Error saving base64 image: $e');
      rethrow;
    }
  }

  // Unified loader for URL or Base64 data URI
  Future<File> downloadOrSaveImage(String imageSource) async {
    if (imageSource.startsWith('data:image')) {
      return saveBase64Image(imageSource);
    } else {
      return downloadAndCacheImage(imageSource);
    }
  }

  bool isValidImageUrl(String url) {
    if (url.trim().isEmpty) return false;
    final uri = Uri.tryParse(url.trim());
    if (uri == null || (!uri.isScheme('http') && !uri.isScheme('https'))) {
      return false;
    }
    return true;
  }
}

