import 'dart:async';

import 'package:chats_ton/Providers/voice_call_provider.dart';
import 'package:flutter/material.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';

import '../Models/user_model.dart';

class CallServiceProvider with ChangeNotifier {
  Call? _call;
  Call? get call => _call;
  int _callDurationSeconds = 0;
  bool _isMicEnabled = false;
  bool _isLoudSpeaker = false;
  bool get isLoudSpeaker => _isLoudSpeaker;
  bool get isMicEnabled => _isMicEnabled;

  loudSpeaker() {
    _isLoudSpeaker = !_isLoudSpeaker;
    // _call!.
    notifyListeners();
  }

  micOnOff() {
    _isMicEnabled = !_isMicEnabled;
    _call!.setMicrophoneEnabled(enabled: !_isMicEnabled);
    notifyListeners();
  }

  int get callDurationSeconds => _callDurationSeconds;
  Timer? _timer;
  String _callStatusMessage = '';

  String get callStatusMessage => _callStatusMessage;

  updateCallMessage(String status) {
    _callStatusMessage = status;
    notifyListeners();
  }

  initializeCall(String callId, String callType, String currentUserId,
      String messageId, UserModel userModel, List<UserModel> members) async {
    updateCallMessage('Connecting...');

    _call = StreamVideo.instance.makeCall(type: 'video', id: callId);
    await _call!.getOrCreate(participantIds: [currentUserId]);
    _call!.setMicrophoneEnabled(enabled: true);
    _isMicEnabled = true;
    for (var element in members) {
      VoiceCallProvider().sendCallNotification(
          recipientToken: element.pushToken,
          userModel: userModel,
          messageId: messageId,
          callId: callId,
          callType: callType);
    }
    updateCallMessage('Connecting...');

    notifyListeners();
  }

  startTimer() async =>
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _callDurationSeconds++;
        notifyListeners();
      });
  closeTime() async {
    _timer!.cancel();
    _callDurationSeconds = 0;
    notifyListeners();
  }

  endCall() async {
    if (_call != null) {
      _call!.end();
    }
  }
}
