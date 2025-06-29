import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/comment.dart';
import '../models/article.dart';
class ApiService {
  static const String baseUrl = 'https://hacker-news.firebaseio.com/v0';

  //on récupere la liste des id dess top stories
  Future<List<int>> fetchTopStoriesIds() async {
    final response = await http.get(Uri.parse('$baseUrl/topstories.json'));

    if (response.statusCode == 200) {
      final List<dynamic> ids = json.decode(response.body);
      return ids.cast<int>();
    } else {
      throw Exception('Erreur lors du chargement des identifianrs');
    }
  }

  Future<Article> fetchArticleById(int id) async {
  final response = await http.get(Uri.parse('$baseUrl/item/$id.json'));
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return Article.fromJson(data);
  } else {
    throw Exception('Erreur lors du chargement de l\'article $id');
  }
}

  Future<Comment> fetchCommentById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/item/$id.json'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Comment.fromMap(data);
    } else {
      throw Exception('Erreur lors du chargement du commentaire $id');
    }
  }

  
}
