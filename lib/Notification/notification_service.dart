import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final Map<String, dynamic> notificationData = message.data;
      print(notificationData);
      handleNotifications(notificationData);
    });
  }

  Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    FirebaseDatabase.instance.setPersistenceEnabled(true);
    print('Firebase Messaging Background');

    final Map<String, dynamic> notificationData = message.data;
    handleNotifications(notificationData);
  }

  handleNotifications(Map<String, dynamic> notificationData) {
    if (notificationData['type'] == 'call') {
      if (notificationData['convType'] == 'group') {
        handleGroupCallNotification(notificationData);
      }
      // Handle call notification in the background
      // You can add your logic here
    } else if (notificationData['type'] == 'message') {
      if (notificationData['convType'] == 'group') {
        handleGroupMessageNotification(notificationData);
      }
      // Handle other types of notifications in the background
      // You can add your logic here
    }
  }

  handleGroupCallNotification(Map<String, dynamic> notificationData) async {
    final sharedPreferences = SharedPreferences.getInstance();
    String groupId = notificationData['groupId'];
    String messageId = notificationData['messageId'];

    await FirebaseDatabase.instance
        .ref()
        .child('groups/$groupId/messages/$messageId/callMessageState')
        .set('Ringing...');
  }

  handleGroupMessageNotification(Map<String, dynamic> notificationData) async {
    final sharedPreferences = SharedPreferences.getInstance();
    String groupId = notificationData['groupId'];
    String messageId = notificationData['messageId'];
    await FirebaseDatabase.instance
        .ref()
        .child('groups/$groupId/messages/$messageId/status')
        .set('delivered');
  }
}
