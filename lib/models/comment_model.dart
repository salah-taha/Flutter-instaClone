import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String authorId;
  final String content;
  final Timestamp timestamp;

  Comment({
    this.timestamp,
    this.authorId,
    this.id,
    this.content,
  });

  factory Comment.fromDoc(DocumentSnapshot doc) {
    return Comment(
        id: doc.documentID,
        content: doc['content'],
        authorId: doc['authorId'],
        timestamp: doc['timestamp']);
  }
}
