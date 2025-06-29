class Comment {
  final int id;
  final String? author;
  final String? text;
  final List<int>? kids;

  Comment({
    required this.id,
    this.author,
    this.text,
    this.kids,
  });
  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'],
      author: map['by'],
      text: map['text'],
      kids: List<int>.from(map['kids'] ?? []),
    );
  }
}
