import 'package:flutter/material.dart';
import '../models/article.dart';
import 'article_detail_screen.dart';
import '../database/favorites_database.dart';
import '../services/api_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Article> favoriteArticles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

 Future<void> loadFavorites() async {
  final articles = await FavoritesDatabase.getFavorites();
  print('📦 Favoris trouvés : ${articles.length}');
  for (var a in articles) {
    print('→ ${a.title} - isFavorite: ${a.isFavorite}');
  }
  setState(() {
    favoriteArticles = articles;
    isLoading = false;
  });
}

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (favoriteArticles.isEmpty) {
      return const Center(child: Text('Aucun article favori.'));
    }

    return ListView.builder(
      itemCount: favoriteArticles.length,
      itemBuilder: (context, index) {
        final article = favoriteArticles[index];
        return Card(
          color: const Color(0xFFFFF7F0),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            title: Text(
              article.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(article.author ?? 'Inconnu'),
                    const SizedBox(width: 16),
                    const Icon(Icons.comment, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('${article.commentCount ?? 0}'),
                  ],
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              final updatedArticle = await ApiService().fetchArticleById(article.id);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ArticleDetailScreen(article: updatedArticle),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
