import 'package:flutter/material.dart';
import '../models/article.dart';
import 'article_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  final List<Article> articles;

  const HomeScreen({super.key, required this.articles});

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        return Card(
          color: const Color(0xFFFFF7F0),
  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  elevation: 2,
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
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ArticleDetailScreen(article: article),
        ),
      );
    },
  ),
);
      },
    );
  }
}