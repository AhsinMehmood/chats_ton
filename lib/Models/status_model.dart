import 'package:cloud_firestore/cloud_firestore.dart';

class StatusModel {
  // final String id;
  final String imageUrl;
  final String timestamp;
  final String postedById;
  List viewerIds;
  final List contactsList;
  final String storyType;

  StatusModel(
      {
      // required this.id,
      required this.imageUrl,
      required this.storyType,
      required this.contactsList,
      required this.timestamp,
      required this.postedById,
      required this.viewerIds});
  factory StatusModel.fromJson(Map<String, dynamic> json) {
    return StatusModel(
        // id: id,
        imageUrl: json['imageUrl'] ?? '',
        storyType: json['storyType'] ?? 'image',
        contactsList: json['contacts'] ?? [],
        timestamp: json['timestamp'] ?? DateTime.now().toIso8601String(),
        postedById: json['postedBy'] ?? '',
        viewerIds: json['viewerIds'] ?? []);
  }
  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'timestamp': timestamp,
      'postedBy': postedById,
      'viewerIds': viewerIds,
      'storyType': storyType,
      'contacts': contactsList,
      // Add other fields here
    };
  }
}
