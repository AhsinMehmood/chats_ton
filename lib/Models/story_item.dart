import 'package:chats_ton/Models/status_model.dart';
import 'package:chats_ton/Models/user_model.dart';

class StoryItemType {
  static const String image = "image";
  static const String video = "video";
}

/// Represents a story with a URL, viewers and type.
class StoryItem {
  /// The URL of the story.
  final String url;

  /// The viewers of the story.
  final List<UserModel> viewers;

  /// The type of the story.
  final String type;
  final StatusModel statusModel;

  // Add a duration property for each StoryItem
  final int? duration;

  /// Constructs a new [StoryItem] instance with the given [url], [viewers], [type] and [duration].
  const StoryItem(
      {required this.url,
      required this.statusModel,
      required this.viewers,
      required this.type,
      this.duration = 3});

  /// Converts this [StoryItem] instance to a JSON format.
  Map<String, dynamic> toJson() =>
      {"url": url, "viewers": viewers, "type": type, "duration": duration};

  /// Converts this [StoryItem] instance to a list of [StoryItem].
  List<StoryItem> toList() => List<StoryItem>.of([this]);
}
