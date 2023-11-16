import 'package:cloud_firestore/cloud_firestore.dart';

class GroupPostModel {
  final String imageUrl;
  final Timestamp createdAt;
  final String userId;
  final String description;
  final List likedBy;
  final List<Comment> comments;
  final String id;

  GroupPostModel(
      {required this.imageUrl,
      required this.createdAt,
      required this.userId,
      required this.description,
      required this.id,
      required this.likedBy,
      required this.comments});

  factory GroupPostModel.fromJson(DocumentSnapshot snapshot) {
    List commentList = snapshot['comments'] ?? [];
    List<Comment> list = [];
    for (var element in commentList) {
      list.add(Comment.fromJson(element));
    }
    return GroupPostModel(
        id: snapshot.id,
        imageUrl: snapshot['imageUrl'] ?? '',
        createdAt: snapshot['createdAt'] ?? FieldValue.serverTimestamp(),
        userId: snapshot['userId'] ?? '',
        description: snapshot['description'] ?? '',
        likedBy: snapshot['likedBy'] ?? [],
        comments: list);
  }
}

class Comment {
  final String commentText;
  final String commentedAt;
  final String commentOwnerId;

  Comment(
      {required this.commentText,
      required this.commentedAt,
      required this.commentOwnerId});
  factory Comment.fromJson(Map data) {
    return Comment(
        commentText: data['commentText'] ?? '',
        commentedAt: data['commentedAt'] ?? DateTime.now().toIso8601String(),
        commentOwnerId: data['commentOwnerId'] ?? '');
  }
}
