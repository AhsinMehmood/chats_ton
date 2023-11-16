import 'dart:io';

import 'package:camera/camera.dart';
import 'package:chats_ton/Providers/group_get_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

import '../../Global/color.dart';

final AppColor app = AppColor();

late List<CameraDescription> cameras;

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   _cameras = await availableCameras();
//   runApp(const CameraApp());
// }

/// CameraApp is the Main Application.
class CameraApp extends StatefulWidget {
  /// Default Constructor
  const CameraApp({super.key});

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController controller;
  int _currentCameraIndex = 0;
  XFile? imageFile;
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (!controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // if (controller != null) {
      // onNewCameraSelected(controller.description);
      // }
    }
  }

  @override
  void initState() {
    super.initState();
    controller =
        CameraController(cameras[_currentCameraIndex], ResolutionPreset.medium);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final GroupService groupService = Provider.of<GroupService>(context);
    if (!controller.value.isInitialized) {
      return Scaffold();
    }
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (imageFile == null) CameraPreview(controller),
          if (imageFile != null) Image.file(File(imageFile!.path)),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 80,
                left: 15,
                right: 15,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () async {
                      if (imageFile == null) {
                        // Switch between front and back cameras
                        int newCameraIndex =
                            (_currentCameraIndex + 1) % cameras.length;

                        // Dispose of the old controller
                        await controller.dispose();

                        // Initialize the new controller with the selected camera
                        controller = CameraController(
                          cameras[newCameraIndex],
                          ResolutionPreset.medium,
                        );

                        _currentCameraIndex = newCameraIndex;

                        // Initialize the new camera controller
                        await controller.initialize();

                        // Update the UI
                        if (mounted) {
                          setState(() {});
                        }
                        // controller.
                      } else {
                        Get.back();
                      }
                    },
                    child: Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                          color: app.changeColor(color: app.purpleColor),
                          borderRadius: BorderRadius.circular(200)),
                      child: Icon(
                        imageFile == null
                            ? Icons.flip_camera_ios_outlined
                            : Icons.close,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  InkWell(
                    // onTapDown: (TapDownDetails details) {

                    //   Future.delayed(const Duration(milliseconds: 300));
                    //   controller.startVideoRecording();
                    // },
                    // onTapUp: (details) {
                    //   Vibration.vibrate();
                    //   controller.stopVideoRecording().then((value) {
                    //     setState(() {
                    //       imageFile = value;
                    //     });
                    //   });
                    // },
                    onTap: () {
                      Vibration.vibrate();
                      controller.takePicture().then((value) {
                        setState(() {
                          imageFile = value;
                        });
                      });
                    },
                    child: Container(
                      height: 60,
                      width: 60,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(color: Colors.red, width: 2),
                          borderRadius: BorderRadius.circular(200)),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(200)),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      if (imageFile == null) {
                        Get.back();
                      }
                      if (imageFile != null) {
                        // selectImageFileAndGoBack
                        groupService.selectImageCamera(File(imageFile!.path));
                        Get.back();
                      }
                    },
                    child: Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                          color: app.changeColor(color: app.purpleColor),
                          borderRadius: BorderRadius.circular(200)),
                      child: Icon(
                        imageFile == null ? Icons.close : Icons.done,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
