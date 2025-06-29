import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'home_screen.dart';
import 'favorites_screen.dart';
import '../models/article.dart';
import '../services/api_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final ApiService api = ApiService();
  List<Article> _articles = [];

  @override
  void initState() {
    super.initState();
    loadArticles();
  }

  Future<void> loadArticles() async {
    final ids = await api.fetchTopStoriesIds();
    final limitedIds = ids.take(20);
    final futures = limitedIds.map((id) => api.fetchArticleById(id));
    final results = await Future.wait(futures);
    setState(() {
      _articles = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeScreen(articles: _articles),
      const FavoritesScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        
        backgroundColor: const Color.fromARGB(255, 242, 210, 179),
        title: Text(_currentIndex == 0 ? 'Articles' : 'Favoris')),
      body: 
      _articles.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        
        backgroundColor: const Color.fromARGB(255, 242, 210, 179),
        currentIndex: _currentIndex,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            
            icon: Icon(Icons.article),
            label: 'Articles',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoris',
          ),
        ],
      ),
    );
  }
}