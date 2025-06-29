class Article {
  final int id;
  final String title;
  final String? author;
  final String? url;
  final int? score;
  final int? commentCount;
  final int? time;
  final List<int>? kids;
  bool isFavorite;

  Article({
    required this.id,
    required this.title,
    this.author,
    this.url,
    this.score,
    this.commentCount,
    this.isFavorite = false, //par defaut on a pas de favori
    this.kids,
    this.time,
  });

//ceci me permet de creer un article a partir d'un JSON de l'API
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      title: json['title'],
      author: json['by'],
      url: json['url'],
      score: json['score'],
      commentCount: (json['kids'] as List?)?.length ?? 0, 
      time: json['time'],
      kids: json['kids'] != null ? List<int>.from(json['kids']): [],
      isFavorite: false,
    );
  }

//ici je convetis un article en map pour sqlite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'url': url,
      'score': score,
      'commentCount': commentCount,
      'isFavorite': isFavorite ? 1 : 0,
      'time': time,
      //on ne rajoute pas kids ici pour des soucis de contraintes
    };


  }

///ceci me permet de creer un article depuis une ligne SQLite
  factory Article.fromMap(Map<String, dynamic> map) {
    return Article(
      id: map['id'],
      title: map['title'],
      author: map['author'],
      url: map['url'],
      score: map['score'],
      commentCount: map['commentCount'],
      isFavorite: map['isFavorite'] == 1,
      time: map['time'],
      ///je n'ai pas ajouté kids parce que c'est une liste et sqlite ne les gere pas directement
    );
  }
  
}
