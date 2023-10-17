import 'package:cloud_firestore/cloud_firestore.dart';

class StatusModel {
  final String id;
  final String imageUrl;
  final Timestamp timestamp;
  final String postedById;
  final List<String> viewerIds;

  StatusModel(
      {required this.id,
      required this.imageUrl,
      required this.timestamp,
      required this.postedById,
      required this.viewerIds});
}
