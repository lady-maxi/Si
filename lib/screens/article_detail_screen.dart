import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/article.dart';
import '../models/comment.dart';
import '../services/api_service.dart';
import '../database/favorites_database.dart';

class _ExpandableReplies extends StatefulWidget {
  final Comment comment;
  final int depth;
  final Future<List<Comment>> Function(List<int>) fetchComments;
  final Widget Function(Comment, {int depth}) buildComment;

  const _ExpandableReplies({
    required this.comment,
    required this.depth,
    required this.fetchComments,
    required this.buildComment,
  });

  @override
  State<_ExpandableReplies> createState() => _ExpandableRepliesState();
}

class _ExpandableRepliesState extends State<_ExpandableReplies> {
  bool showReplies = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton(
          onPressed: () {
            setState(() {
              showReplies = !showReplies;
            });
          },
          child: Text(
            showReplies ? 'Masquer les réponses' : 'Voir les réponses',
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.deepOrange,
            ),
          ),
        ),
        if (showReplies)
          FutureBuilder<List<Comment>>(
            future: widget.fetchComments(widget.comment.kids!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text("Chargement des réponses..."),
                );
              } else if (snapshot.hasError) {
                return const Text("Erreur lors du chargement des réponses");
              } else {
                return Column(
                  children: snapshot.data!
                      .map((child) => widget.buildComment(child, depth: widget.depth + 1))
                      .toList(),
                );
              }
            },
          ),
      ],
    );
  }
}

class ArticleDetailScreen extends StatefulWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  final ApiService api = ApiService();
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    checkIfFavorite();
  }

  Future<void> checkIfFavorite() async {
    final result = await FavoritesDatabase.isFavorite(widget.article.id);
    setState(() {
      isFavorite = result;
    });
  }

  Future<void> toggleFavorite() async {
    setState(() {
      isFavorite = !isFavorite;
      widget.article.isFavorite = isFavorite;
    });

      if (isFavorite) {
    await FavoritesDatabase.addFavorite(widget.article);
    print('Ajouté dans SQLite : ${widget.article.title}');
  } else {
    await FavoritesDatabase.removeFavorite(widget.article.id);
    print('Supprimé de SQLite : ${widget.article.title}');
  }
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Impossible d’ouvrir le lien';
    }
  }

  Future<List<Comment>> fetchComments(List<int> ids) async {
    List<Comment> comments = [];
    for (var id in ids) {
      try {
        final comment = await api.fetchCommentById(id);
        comments.add(comment);
      } catch (e) {
        // on ignore les erreurs
      }
    }
    return comments;
  }

  Widget buildComment(Comment comment, {int depth = 0}) {
    return Padding(
      padding: EdgeInsets.only(left: depth * 12.0, top: 8, bottom: 8, right: 8),
      child: Card(
        color: const Color(0xFFFFF7F0),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                comment.author ?? 'Anonyme',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              if (comment.text != null)
                Text(
                  comment.text!.replaceAll(RegExp(r'<[^>]*>'), ''),
                ),
              if (comment.kids != null && comment.kids!.isNotEmpty)
                _ExpandableReplies(
                  comment: comment,
                  depth: depth,
                  fetchComments: fetchComments,
                  buildComment: buildComment,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final commentIds = widget.article.kids ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 242, 210, 179),
        title: Text(widget.article.title),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.deepOrange : Colors.orange.shade200,
            ),
            onPressed: toggleFavorite,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Auteur : ${widget.article.author ?? "inconnu"}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            if (widget.article.url != null)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 242, 210, 179),
                  foregroundColor: const Color.fromARGB(255, 22, 25, 27),
                ),
                onPressed: () => _launchURL(widget.article.url!),
                child: const Text('Lire l\'article'),
              ),
            const SizedBox(height: 24),
            Text('Commentaires (${commentIds.length})', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
  child: FutureBuilder<List<Comment>>(
    future: fetchComments(widget.article.kids ?? []),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return const Center(child: Text('Erreur de chargement'));
      } else if (snapshot.data!.isEmpty) {
        return const Center(child: Text('Aucun commentaire.'));
      } else {
        return ListView(
          children: snapshot.data!
              .map((comment) => buildComment(comment))
              .toList(),
        );
      }
    },
  ),
)
          ],
        ),
      ),
    );
  }
}