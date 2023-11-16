// ignore_for_file: use_build_context_synchronously, library_prefixes

import 'package:camera/camera.dart';
import 'package:chats_ton/Global/color.dart';
import 'package:chats_ton/Models/chats_model.dart';
import 'package:chats_ton/Models/user_model.dart';
import 'package:chats_ton/Notification/notification_service.dart';
import 'package:chats_ton/Providers/app_provider.dart';
import 'package:chats_ton/Providers/call_service_provider.dart';
import 'package:chats_ton/Providers/contacts_provider.dart';
import 'package:chats_ton/Providers/conversation_provider.dart';
import 'package:chats_ton/Providers/group_post_provider.dart';
import 'package:chats_ton/Providers/group_provider.dart';
import 'package:chats_ton/Providers/message_provider.dart';
import 'package:chats_ton/Providers/status_provider.dart';
import 'package:chats_ton/Providers/user_provider.dart';
import 'package:chats_ton/UI/splash_screen.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart' as chatClientSDK;
// import 'package:stream_chat_persistence/stream_chat_persistence.dart';

// import 'package:video_player_media_kit/video_player_media_kit.dart';

// import 'UI/Calling/video_call_page.dart';
import 'Providers/group_get_controller.dart';
import 'UI/Pages/camera_view.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  // runApp(MyNewApp());
  final Map<String, dynamic> notificationData = message.data;
  print(notificationData.toString() + ' Background Handler');
  NotificationService().handleNotifications(notificationData);
}

final navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FastCachedImageConfig.init(clearCacheAfter: const Duration(days: 15));

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  cameras = await availableCameras();

  final client = chatClientSDK.StreamChatClient(
    chatApiKey,
    logLevel: chatClientSDK.Level.OFF,
  );

//   StreamVideo.in(
//   "us83cfwuhy8n",
//   logLevel: Level.INFO,
// );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  /// 1.1.2: set navigator key to ZegoUIKitPrebuiltCallInvitationService

  runApp(
    MultiProvider(
      providers: [
        StreamProvider<UserModel>.value(
          value: UserProvider().getUserStream(),
          initialData: UserModel.fromJson({}, ''),
        ),
        StreamProvider<List<ChatsModel>>.value(
          value: ConversationProvider().chatsStream(),
          catchError: (context, error) {
            return [];
          },
          initialData: const [],
        ),
        ChangeNotifierProvider<AppProvider>(create: (context) => AppProvider()),
        ChangeNotifierProvider<MessageProvider>(
            create: (context) => MessageProvider()),
        ChangeNotifierProvider<UserProvider>(
            create: (context) => UserProvider()),
        ChangeNotifierProvider<StatusProvider>(
            create: (context) => StatusProvider()),
        ChangeNotifierProvider<ContactsProvider>(
            create: (context) => ContactsProvider()),
        ChangeNotifierProvider<ConversationProvider>(
            create: (context) => ConversationProvider()),
        ChangeNotifierProvider<GroupProvider>(
            create: (context) => GroupProvider()),
        ChangeNotifierProvider<GroupPostProvider>(
            create: (context) => GroupPostProvider()),
        ChangeNotifierProvider<GroupController>(
            create: (context) => GroupController()),
        ChangeNotifierProvider<GroupService>(
            create: (context) => GroupService()),
        ChangeNotifierProvider<CallServiceProvider>(
            create: (context) => CallServiceProvider()),
      ],
      child: MyApp(
        navigatorKey: navigatorKey,
        client: client,
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final chatClientSDK.StreamChatClient client;

  final GlobalKey<NavigatorState> navigatorKey;

  const MyApp({
    super.key,
    required this.navigatorKey,
    required this.client,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final Map<String, dynamic> notificationData = message.data;
      print(notificationData.toString() + ' Actuv Handler');

      NotificationService().handleNotifications(notificationData);
    });
  }

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
    //     overlays: [SystemUiOverlay.top]);

    return GetMaterialApp(
      title: 'Chats Ton',
      // useInheritedMediaQuery: true,
      // locale: DevicePreview.locale(context),
      // builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      navigatorKey: widget.navigatorKey,
      builder: (context, child) => chatClientSDK.StreamChat(
        client: widget.client,
        streamChatThemeData: chatClientSDK.StreamChatThemeData(
          reactionIcons: [
            chatClientSDK.StreamReactionIcon(
                type: 'love',
                builder: (context, value, ss) {
                  return const Icon(Icons.heart_broken);
                })
          ],
          channelHeaderTheme: chatClientSDK.StreamChannelHeaderThemeData(
            subtitleStyle: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w400,
            ),
            titleStyle: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          otherMessageTheme: chatClientSDK.StreamMessageThemeData(
              reactionsMaskColor:
                  AppColor().changeColor(color: AppColor().purpleColor)),
          ownMessageTheme: chatClientSDK.StreamMessageThemeData(
              messageTextStyle: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),

              // ignore: deprecated_member_use
              linkBackgroundColor:
                  AppColor().changeColor(color: AppColor().purpleColor),
              messageLinksStyle: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              reactionsMaskColor:
                  AppColor().changeColor(color: AppColor().purpleColor),
              messageBackgroundColor:
                  AppColor().changeColor(color: AppColor().purpleColor)),
          colorTheme: chatClientSDK.StreamColorTheme.light(
              accentPrimary:
                  AppColor().changeColor(color: AppColor().purpleColor)),
        ),
        child: child!,
      ),

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColor().changeColor(color: AppColor().purpleColor),
          primary: AppColor().changeColor(color: AppColor().purpleColorDim),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      ),
      home: const SplashScreen(
          // title: '',
          ),
    );
  }
}
