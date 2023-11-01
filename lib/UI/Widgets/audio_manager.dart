// import 'dart:io';

// import 'package:audio_waveforms/audio_waveforms.dart';
// import 'package:flutter_cache_manager/flutter_cache_manager.dart';

// class AudioPlayerManager {
//   late PlayerController _playerController;
//   int _currentlyPlayingIndex = -1;

//   AudioPlayerManager() {
//     _playerController = PlayerController();
//   }
//   Future<void> prepareThePlayer(String audioUrl) async {}

//   Future<void> playAudio(int index, String audioSrc) async {
//     if (_currentlyPlayingIndex != -1) {
//       // Pause the currently playing audio
//       await _playerController.pausePlayer();
//     }

//     // Play the new audio
//     File file = await DefaultCacheManager().getSingleFile(audioSrc);
//     await _playerController.preparePlayer(
//       path: file.path,
//       shouldExtractWaveform: false,
//       // noOfSamples: 100,
//       volume: 1.0,
//     );
//     await _playerController.startPlayer(finishMode: FinishMode.stop);

//     _currentlyPlayingIndex = index;
//   }

//   void stopAudio(int i) {
//     if (_currentlyPlayingIndex != -1) {
//       // Stop the currently playing audio
//       _playerController.stopPlayer();
//       _currentlyPlayingIndex = -1;
//     }
//   }

//   void dispose() {
//     _playerController.dispose();
//   }
// }
