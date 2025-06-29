import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/article.dart';

class FavoritesDatabase {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    return await _initDB();
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'favorites.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  static Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY,
        title TEXT,
        author TEXT,
        url TEXT,
        score INTEGER,
        commentCount INTEGER,
        time INTEGER,
        isFavorite INTEGER
      )
    ''');
  }

//on insere l'aticle qu'on veut fav dans la BDD
  static Future<void> addFavorite(Article article) async {
  final db = await database;
  try {
    await db.insert(
      'favorites',
      article.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('✅ Ajouté dans SQLite : ${article.title}');
  } catch (e) {
    print('❌ Erreur lors de l\'insertion : $e');
  }
}

//on supprime un fav par son id
  static Future<void> removeFavorite(int id) async {
    final db = await database;
    await db.delete('favorites', where: 'id= ?', whereArgs: [id]);
  }

//affiche les favoris
  static Future<List<Article>> getFavorites() async {
  final db = await database;
  final maps = await db.query('favorites');
  print('Lecture en base, nombre d’articles: ${maps.length}');
  for (var map in maps) {
    print('Article: ${map['title']}, auteur: ${map['author']}');
  }
  return List.generate(maps.length, (i) => Article.fromMap(maps[i]));
}

//on verifie ici si un element est favoris
  static Future<bool> isFavorite(int id) async {
    final db = await database;
    final maps = await db.query(
      'favorites',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty;
  }
}
