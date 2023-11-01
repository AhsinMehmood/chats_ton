import 'package:chats_ton/Global/color.dart';
import 'package:chats_ton/Models/user_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import '../Pages/message_page.dart';

class ChatListWidget extends StatefulWidget {
  const ChatListWidget({
    super.key,
    required this.app,
  });

  final AppColor app;

  @override
  State<ChatListWidget> createState() => _ChatListWidgetState();
}

class _ChatListWidgetState extends State<ChatListWidget> {
  late final _listController = StreamChannelListController(
    client: StreamChat.of(context).client,
    filter: Filter.and([
      Filter.equal('type', 'messaging'),
      // Filter.contains('key', value)
      Filter.in_(
        'members',
        [StreamChat.of(context).currentUser!.id],
      ),
    ]),
    sort: const [SortOption('last_message_at')],
    limit: 50,
  );
  @override
  void dispose() {
    super.dispose();
    _listController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final List<ChatsModel> chatsList = Provider.of<List<ChatsModel>>(context);
    final UserModel currentUser = Provider.of<UserModel>(context);
    return Container(
      margin: const EdgeInsets.only(
        top: 250,
      ),
      height: Get.height - 250,
      width: Get.width,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          )),
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Container(
            height: 3,
            width: 30,
            color: widget.app.changeColor(color: 'E6E6E6'),
          ),
          const SizedBox(
            height: 10,
          ),

          // if (chatsList.isEmpty) const Text('No chats'),
          Expanded(
            child: StreamChannelListView(
              controller: _listController,
              itemBuilder: (context, items, index, defaultWidget) {
                final channel = items[index];

                return defaultWidget.copyWith(
                  onTap: () {
                    Get.to(() => StreamChannel(
                        showLoading: false,
                        channel: channel,
                        child: const ChannelPage()));
                  },
                  channel: channel,
                  leading: StreamChannelAvatar(channel: channel),
                  contentPadding: const EdgeInsets.only(left: 15, right: 15),
                );

                // StreamChannelListTile(
                //   channel: channel,
                //   onTap: () {
                //     Navigator.of(context).push(
                //       MaterialPageRoute(
                //         builder: (context) {
                // return
                //         },
                //       ),
                //     );
                //   },
                //   contentPadding: const EdgeInsets.only(
                //     left: 15,
                //     right: 10,
                //     bottom: 10,
                //   ),
                // );
              },
            ),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}

// class StreamChannelListTile extends StatelessWidget {
//   StreamChannelListTile({
//     super.key,
//     required this.channel,
//     this.leading,
//     this.title,
//     this.subtitle,
//     this.trailing,
//     this.onTap,
//     this.onLongPress,
//     this.tileColor,
//     this.visualDensity = VisualDensity.compact,
//     this.contentPadding = const EdgeInsets.symmetric(horizontal: 8),
//     this.unreadIndicatorBuilder,
//     this.sendingIndicatorBuilder,
//     this.selected = false,
//     this.selectedTileColor,
//   }) : assert(
//           channel.state != null,
//           'Channel ${channel.id} is not initialized',
//         );

//   /// The channel to display.
//   final Channel channel;

//   /// A widget to display before the title.
//   final Widget? leading;

//   /// The primary content of the list tile.
//   final Widget? title;

//   /// Additional content displayed below the title.
//   final Widget? subtitle;

//   /// A widget to display at the end of tile.
//   final Widget? trailing;

//   /// Called when the user taps this list tile.
//   final GestureTapCallback? onTap;

//   /// Called when the user long-presses on this list tile.
//   final GestureLongPressCallback? onLongPress;

//   final Color? tileColor;

//   final VisualDensity visualDensity;

//   final EdgeInsetsGeometry contentPadding;

//   final WidgetBuilder? unreadIndicatorBuilder;

//   final Widget Function(BuildContext, Message)? sendingIndicatorBuilder;

//   final bool selected;

//   final Color? selectedTileColor;

//   StreamChannelListTile copyWith({
//     Key? key,
//     Channel? channel,
//     Widget? leading,
//     Widget? title,
//     Widget? subtitle,
//     VoidCallback? onTap,
//     VoidCallback? onLongPress,
//     VisualDensity? visualDensity,
//     EdgeInsetsGeometry? contentPadding,
//     bool? selected,
//     Widget Function(BuildContext, Message)? sendingIndicatorBuilder,
//     Color? tileColor,
//     Color? selectedTileColor,
//     WidgetBuilder? unreadIndicatorBuilder,
//     Widget? trailing,
//   }) {
//     return StreamChannelListTile(
//       key: key ?? this.key,
//       channel: channel ?? this.channel,
//       leading: leading ?? this.leading,
//       title: title ?? this.title,
//       subtitle: subtitle ?? this.subtitle,
//       onTap: onTap ?? this.onTap,
//       onLongPress: onLongPress ?? this.onLongPress,
//       visualDensity: visualDensity ?? this.visualDensity,
//       contentPadding: contentPadding ?? this.contentPadding,
//       sendingIndicatorBuilder:
//           sendingIndicatorBuilder ?? this.sendingIndicatorBuilder,
//       tileColor: tileColor ?? this.tileColor,
//       trailing: trailing ?? this.trailing,
//       unreadIndicatorBuilder:
//           unreadIndicatorBuilder ?? this.unreadIndicatorBuilder,
//       selected: selected ?? this.selected,
//       selectedTileColor: selectedTileColor ?? this.selectedTileColor,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final channelState = channel.state!;
//     final currentUser = channel.client.state.currentUser!;

//     final channelPreviewTheme = StreamChannelPreviewTheme.of(context);
//     final streamChatTheme = StreamChatTheme.of(context);
//     final streamChat = StreamChat.of(context);

//     final leading = this.leading ??
//         StreamChannelAvatar(
//           channel: channel,
//           borderRadius: BorderRadius.circular(200),
//           constraints: const BoxConstraints(
//             minWidth: 90,
//             minHeight: 90,
//           ),
//         );

//     final title = this.title ??
//         StreamChannelName(
//           channel: channel,
//           textStyle: GoogleFonts.poppins(
//             color: Colors.black,
//             fontSize: 15,
//             fontWeight: FontWeight.w600,
//           ),
//         );

//     final subtitle = this.subtitle ??
//         ChannelListTileSubtitle(
//           channel: channel,
//           textStyle: GoogleFonts.poppins(
//             color: Colors.black,
//             fontSize: 14,
//             fontWeight: FontWeight.w400,
//           ),
//         );

//     final trailing = this.trailing ??
//         ChannelLastMessageDate(
//           channel: channel,
//           textStyle: GoogleFonts.poppins(
//             color: Colors.black,
//             fontSize: 12,
//             fontWeight: FontWeight.w500,
//           ),
//         );

//     return BetterStreamBuilder<bool>(
//       stream: channel.isMutedStream,
//       initialData: channel.isMuted,
//       builder: (context, isMuted) => AnimatedOpacity(
//         opacity: isMuted ? 0.5 : 1,
//         duration: const Duration(milliseconds: 300),
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: ListTile(
//             onTap: onTap,
//             onLongPress: onLongPress,
//             visualDensity: visualDensity,
//             contentPadding: contentPadding,
//             leading: leading,
//             tileColor: tileColor,
//             selected: selected,
//             selectedTileColor: selectedTileColor ??
//                 StreamChatTheme.of(context).colorTheme.borders,
//             title: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(child: title),
//                 BetterStreamBuilder<List<Member>>(
//                   stream: channelState.membersStream,
//                   initialData: channelState.members,
//                   comparator: const ListEquality().equals,
//                   builder: (context, members) {
//                     if (members.isEmpty) {
//                       return const Offstage();
//                     }
//                     return unreadIndicatorBuilder?.call(context) ??
//                         UnreadIndicator(cid: channel.cid);
//                   },
//                 ),
//               ],
//             ),
//             subtitle: Row(
//               children: [
//                 Expanded(
//                   child: Align(
//                     alignment: Alignment.centerLeft,
//                     child: subtitle,
//                   ),
//                 ),
//                 BetterStreamBuilder<List<Message>>(
//                   stream: channelState.messagesStream,
//                   initialData: channelState.messages,
//                   comparator: const ListEquality().equals,
//                   builder: (context, messages) {
//                     final lastMessage = messages.lastWhereOrNull(
//                       (m) => !m.shadowed && !m.isDeleted,
//                     );

//                     if (lastMessage == null ||
//                         (lastMessage.user?.id != currentUser.id)) {
//                       return const Offstage();
//                     }

//                     final hasNonUrlAttachments = lastMessage.attachments
//                         .where(
//                             (it) => it.titleLink == null || it.type == 'giphy')
//                         .isNotEmpty;

//                     return Padding(
//                       padding: const EdgeInsets.only(right: 4),
//                       child:
//                           sendingIndicatorBuilder?.call(context, lastMessage) ??
//                               SendingIndicatorBuilder(
//                                 messageTheme: streamChatTheme.ownMessageTheme,
//                                 message: lastMessage,
//                                 hasNonUrlAttachments: hasNonUrlAttachments,
//                                 streamChat: streamChat,
//                                 streamChatTheme: streamChatTheme,
//                                 channel: channel,
//                               ),
//                     );
//                   },
//                 ),
//                 trailing,
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class UnreadIndicator extends StatelessWidget {
//   /// {@macro UnreadIndicator}
//   const UnreadIndicator({
//     super.key,
//     this.cid,
//   });

//   /// Channel cid used to retrieve unread count
//   final String? cid;

//   @override
//   Widget build(BuildContext context) {
//     final client = StreamChat.of(context).client;
//     return IgnorePointer(
//       child: BetterStreamBuilder<int>(
//         stream: cid != null
//             ? client.state.channels[cid]?.state?.unreadCountStream
//             : client.state.totalUnreadCountStream,
//         initialData: cid != null
//             ? client.state.channels[cid]?.state?.unreadCount
//             : client.state.totalUnreadCount,
//         builder: (context, data) {
//           if (data == 0) {
//             return const Offstage();
//           }
//           return Material(
//             borderRadius: BorderRadius.circular(8),
//             color: StreamChatTheme.of(context)
//                 .channelPreviewTheme
//                 .unreadCounterColor,
//             child: Padding(
//               padding: const EdgeInsets.only(
//                 left: 5,
//                 right: 5,
//                 top: 2,
//                 bottom: 1,
//               ),
//               child: Center(
//                 child: Text(
//                   '${data > 99 ? '99+' : data}',
//                   style: GoogleFonts.poppins(
//                     color: Colors.black,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class SendingIndicatorBuilder extends StatelessWidget {
//   /// {@macro sendingIndicatorWrapper}
//   const SendingIndicatorBuilder({
//     super.key,
//     required this.messageTheme,
//     required this.message,
//     required this.hasNonUrlAttachments,
//     required this.streamChat,
//     required this.streamChatTheme,
//     this.channel,
//   });

//   /// {@macro messageTheme}
//   final StreamMessageThemeData messageTheme;

//   /// {@macro message}
//   final Message message;

//   /// {@macro hasNonUrlAttachments}
//   final bool hasNonUrlAttachments;

//   /// {@macro streamChat}
//   final StreamChatState streamChat;

//   /// {@macro streamChatThemeData}
//   final StreamChatThemeData streamChatTheme;

//   /// {@macro channel}
//   final Channel? channel;

//   @override
//   Widget build(BuildContext context) {
//     final style = messageTheme.createdAtStyle;
//     final channel = this.channel ?? StreamChannel.of(context).channel;
//     final memberCount = channel.memberCount ?? 0;

//     if (hasNonUrlAttachments && message.state.isOutgoing) {
//       final totalAttachments = message.attachments.length;
//       final attachmentsToUpload = message.attachments.where((it) {
//         return !it.uploadState.isSuccess;
//       });

//       if (attachmentsToUpload.isNotEmpty) {
//         return Text(
//           context.translations.attachmentsUploadProgressText(
//             remaining: attachmentsToUpload.length,
//             total: totalAttachments,
//           ),
//           style: style,
//         );
//       }
//     }

//     return BetterStreamBuilder<List<Read>>(
//       stream: channel.state?.readStream,
//       initialData: channel.state?.read,
//       builder: (context, data) {
//         final readList = data.where((it) =>
//             it.user.id != streamChat.currentUser?.id &&
//             (it.lastRead.isAfter(message.createdAt) ||
//                 it.lastRead.isAtSameMomentAs(message.createdAt)));

//         final isMessageRead = readList.isNotEmpty;
//         Widget child = StreamSendingIndicator(
//           message: message,
//           isMessageRead: isMessageRead,
//           size: style?.fontSize,
//         );

//         if (isMessageRead) {
//           child = Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               if (memberCount > 2)
//                 Text(
//                   readList.length.toString(),
//                   style: style?.copyWith(
//                     color: streamChatTheme.colorTheme.accentPrimary,
//                   ),
//                 ),
//               const SizedBox(width: 2),
//               child,
//             ],
//           );
//         }

//         return child;
//       },
//     );
//   }
// }

// /// A widget that displays the channel last message date.
// class ChannelLastMessageDate extends StatelessWidget {
//   /// Creates a new instance of the [ChannelLastMessageDate] widget.
//   ChannelLastMessageDate({
//     super.key,
//     required this.channel,
//     this.textStyle,
//   }) : assert(
//           channel.state != null,
//           'Channel ${channel.id} is not initialized',
//         );

//   /// The channel to display the last message date for.
//   final Channel channel;

//   /// The style of the text displayed
//   final TextStyle? textStyle;

//   @override
//   Widget build(BuildContext context) => BetterStreamBuilder<DateTime>(
//         stream: channel.lastMessageAtStream,
//         initialData: channel.lastMessageAt,
//         builder: (context, data) {
//           final lastMessageAt = data.toLocal();

//           String stringDate;
//           final now = DateTime.now();

//           final startOfDay = DateTime(now.year, now.month, now.day);

//           if (lastMessageAt.millisecondsSinceEpoch >=
//               startOfDay.millisecondsSinceEpoch) {
//             stringDate = Jiffy.parseFromDateTime(lastMessageAt.toLocal()).jm;
//           } else if (lastMessageAt.millisecondsSinceEpoch >=
//               startOfDay
//                   .subtract(const Duration(days: 1))
//                   .millisecondsSinceEpoch) {
//             stringDate = context.translations.yesterdayLabel;
//           } else if (startOfDay.difference(lastMessageAt).inDays < 7) {
//             stringDate = Jiffy.parseFromDateTime(lastMessageAt.toLocal()).EEEE;
//           } else {
//             stringDate = Jiffy.parseFromDateTime(lastMessageAt.toLocal()).yMd;
//           }

//           return Text(
//             stringDate,
//             style: textStyle,
//           );
//         },
//       );
// }

// /// A widget that displays the subtitle for [StreamChannelListTile].
// class ChannelListTileSubtitle extends StatelessWidget {
//   /// Creates a new instance of [StreamChannelListTileSubtitle] widget.
//   ChannelListTileSubtitle({
//     super.key,
//     required this.channel,
//     this.textStyle,
//   }) : assert(
//           channel.state != null,
//           'Channel ${channel.id} is not initialized',
//         );

//   /// The channel to create the subtitle from.
//   final Channel channel;

//   /// The style of the text displayed
//   final TextStyle? textStyle;

//   @override
//   Widget build(BuildContext context) {
//     if (channel.isMuted) {
//       return Row(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: <Widget>[
//           StreamSvgIcon.mute(size: 16),
//           Text(
//             '  ${context.translations.channelIsMutedText}',
//             style: textStyle,
//           ),
//         ],
//       );
//     }
//     return StreamTypingIndicator(
//       channel: channel,
//       style: textStyle,
//       alternativeWidget: ChannelLastMessageText(
//         channel: channel,
//         textStyle: textStyle,
//       ),
//     );
//   }
// }

// /// A widget that displays the last message of a channel.
// class ChannelLastMessageText extends StatefulWidget {
//   /// Creates a new instance of [ChannelLastMessageText] widget.
//   ChannelLastMessageText({
//     super.key,
//     required this.channel,
//     this.textStyle,
//   }) : assert(
//           channel.state != null,
//           'Channel ${channel.id} is not initialized',
//         );

//   /// The channel to display the last message of.
//   final Channel channel;

//   /// The style of the text displayed
//   final TextStyle? textStyle;

//   @override
//   State<ChannelLastMessageText> createState() => _ChannelLastMessageTextState();
// }

// class _ChannelLastMessageTextState extends State<ChannelLastMessageText> {
//   Message? _lastMessage;

//   @override
//   Widget build(BuildContext context) => BetterStreamBuilder<List<Message>>(
//         stream: widget.channel.state!.messagesStream,
//         initialData: widget.channel.state!.messages,
//         builder: (context, messages) {
//           final lastMessage = messages.lastWhereOrNull(
//             (m) => !m.shadowed && !m.isDeleted,
//           );

//           if (widget.channel.state?.isUpToDate == true) {
//             _lastMessage = lastMessage;
//           }

//           if (_lastMessage == null) return const Offstage();

//           return StreamMessagePreviewText(
//             message: _lastMessage!,
//             textStyle: widget.textStyle,
//             language: widget.channel.client.state.currentUser?.language,
//           );
//         },
//       );
// }
