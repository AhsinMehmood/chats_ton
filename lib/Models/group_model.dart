import 'dart:typed_data';

class GroupModel {
  final String groupChatId;
  final String groupName;
  final String groupImage;
  final Map<String, Member> members;
  final String description;
  final Map<String, Message> messages;
  final Map<String, bool> mutedUsers;
  final String id;

  GroupModel({
    required this.groupChatId,
    required this.groupName,
    required this.groupImage,
    required this.members,
    required this.description,
    required this.messages,
    required this.id,
    required this.mutedUsers,
  });

  factory GroupModel.fromMap(String key, Map<dynamic, dynamic> data) {
    // Map<String, Message> messagesData = data['messages'] ?? {};
    // print(messagesData);

    return GroupModel(
      groupChatId: key,
      id: data['groupChatId'],
      groupImage: data['groupImage'] ??
          'https://firebasestorage.googleapis.com/v0/b/chats-ton.appspot.com/o/avatar-1577909_1280.png?alt=media&token=c72d3dd0-722f-45b4-81a1-51ceeb06d29a',
      groupName: data['groupName'],
      members: (data['members'] as Map<dynamic, dynamic>).map(
        (key, value) => MapEntry(key, Member.fromMap(value, key)),
      ),
      description: data['description'],
      messages: (data['messages'] is Map<dynamic, dynamic>)
          ? (data['messages'] as Map<dynamic, dynamic>).map(
              (key, value) => MapEntry(key, Message.fromMap(value, key)),
            )
          : {},
      mutedUsers: (data['mutedUsers'] as Map<dynamic, dynamic>).map(
        (key, value) => MapEntry(key, value as bool),
      ),
    );
  }
  Message? getLastMessage() {
    // Get a list of all messages and sort them by timestamp in descending order
    final sortedMessages = messages.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Return the first (i.e., the most recent) message
    return sortedMessages.isNotEmpty ? sortedMessages.first : null;
  }

  int getUnreadMessageCount(String currentUserId) {
    int unreadCount = 0;

    for (final message in messages.values) {
      if (message.timestamp >
          (members[currentUserId]?.lastReadTimestamp ?? 0)) {
        unreadCount++;
      }
    }

    return unreadCount;
  }
}

class Member {
  final String role;
  final int lastReadTimestamp;
  final String memberId;
  final bool pendingInvite;
  final bool isCreator;

  Member(
      {required this.role,
      required this.memberId,
      required this.isCreator,
      required this.pendingInvite,
      required this.lastReadTimestamp});

  factory Member.fromMap(Map<dynamic, dynamic> data, String id) {
    return Member(
      pendingInvite: data['pendingInvite'] ?? true,
      memberId: id,
      isCreator: data['isCreator'] ?? false,
      lastReadTimestamp: data['lastReadTimestamp'] ?? 00000,
      role: data['role'],
    );
  }
}

class Message {
  final String senderId;
  final String text;
  final String messageId;
  final int timestamp;
  final List readByUserIds;
  final String messageType;
  final Map<String, Media> medias;
  final String status;
  final String callMessageState;

  Message({
    required this.senderId,
    required this.messageType,
    required this.medias,
    required this.text,
    required this.callMessageState,
    required this.messageId,
    required this.timestamp,
    required this.status,
    required this.readByUserIds,
  });

  factory Message.fromMap(Map<dynamic, dynamic> data, String id) {
    Map<dynamic, dynamic>? mediaData = data['media'];
    Map<String, Media> medias = {};

    if (mediaData != null) {
      medias = mediaData.map(
        (key, value) => MapEntry(key, Media.fromMap(value, key)),
      );
    }

    return Message(
      senderId: data['senderId'],
      medias: medias,
      callMessageState: data['callMessageState'] ?? 'Connecting',
      messageType: data['messageType'] ?? 'text',
      messageId: id,
      status: data['status'] ?? 'sent',
      text: data['text'],
      readByUserIds: data['readByUserIds'] ?? [],
      timestamp: data['timestamp'],
    );
  }
}

class Media {
  final String thumbnailUrl;
  final String fileUrl;
  final String type;

  Media(
      {required this.thumbnailUrl, required this.fileUrl, required this.type});
  factory Media.fromMap(Map<dynamic, dynamic> data, String id) {
    return Media(
        thumbnailUrl: data['thumbnailUrl'],
        fileUrl: data['fileUrl'],
        type: data['type']);
  }
}

class GroupedMessages {
  final DateTime date;
  final List<Message> messages;

  GroupedMessages({required this.date, required this.messages});
}
