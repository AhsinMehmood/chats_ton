import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chats_ton/Models/story_item.dart';
import 'package:chats_ton/Models/user_model.dart';
import 'package:chats_ton/Providers/status_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_story_view/models/user_info.dart';
import 'package:flutter_story_view/widgets/story_image.dart';
import 'package:flutter_story_view/widgets/story_indicator.dart';
import 'package:flutter_story_view/widgets/story_video.dart';

import '../../Global/color.dart';
import '../../Providers/contacts_provider.dart';

/// A StatefulWidget that displays a series of story items with a customizable
/// progress indicator and user-defined callback functions for navigation and
/// completion events.
///
/// The `FlutterStoryView` takes a list of `StoryItem` objects, and displays them
/// one at a time, advancing to the next item after a specified duration.
///
/// The widget also provides a set of callback functions that can be used to
/// handle user interactions, such as tapping on the screen to pause, resume,
/// or navigate between story items.
///
/// The `onComplete` callback is triggered when all items have been displayed,
/// while the `onPageChanged` callback is triggered every time the currently
/// displayed item changes.

/// [OnPageChanged] is called when a story item changes
typedef OnPageChanged(int);

class FlutterStoryView extends StatefulWidget {
  /// This Calls when story is completed
  final VoidCallback onComplete;

  /// [OnPageChanged] is called when a story item changes
  final OnPageChanged onPageChanged;

  final VoidCallback? onMenuTapListener;

  // final List<StoryItem> storyItems;
  // Optional caption for the story
  final String? caption;

  /// User Info e.g username and profile image
  final UserModel? userInfo;

  /// Time when the story has been created
  final DateTime? createdAt;

  /// Height of the indicator
  final double? indicatorHeight;

  // Background color of indicator
  final Color? indicatorColor;

  // Background color of indicator
  final Color? indicatorValueColor;

  final bool? enableOnHoldHide;

  FlutterStoryView(
      {required this.onComplete,
      required this.onPageChanged,
      this.caption,
      this.onMenuTapListener,
      this.userInfo,
      this.createdAt,
      // required this.storyItems,
      this.indicatorHeight,
      this.indicatorColor,
      this.indicatorValueColor,
      this.enableOnHoldHide = true});

  @override
  _FlutterStoryViewState createState() => _FlutterStoryViewState();
}

class _FlutterStoryViewState extends State<FlutterStoryView>
    with TickerProviderStateMixin {
  /// Main Controller
  AnimationController? _animationController;
  VideoPlayerController? _videoController;
  Animation<double>? _animation;

  /// current story item index
  int currentItemIndex = 0;

  /// current progress
  double _progress = 0;

  /// This [_tapDownTime] to indicate how long the story is being hold on finger
  /// so that we can easily find out to resume timer or switch to the next page.
  DateTime? _tapDownTime;

  /// This [_timer] is used to determine if the onTapDown is holded for 200 milliseconds
  /// long or less than this. So that we can find out to go to Next story or
  /// just hide the top and bottom menu on hold.
  Timer? _timer;

  bool _isVideoLoading = false;

  bool _isPaused = false;

  @override
  void initState() {
    super.initState();

    /// Start playing the story by calling _playStory method
    _playStory(currentItemIndex);
    // Notify the onPageChanged callback about the current item index
    widget.onPageChanged(currentItemIndex);
  }

  // Start playing the story at the given index
  void _playStory(int index) {
    final UserModel userModel = Provider.of<UserModel>(context, listen: false);

    final ContactsProvider contactsProvider =
        Provider.of<ContactsProvider>(context, listen: false);
    print(userModel.firstName);
    List<StoryItem> stories = [];
    List<UserModel> filteredContacts = [];

    for (var status in userModel.statusList) {
      // Use the `any` method to check if any of the viewer IDs in the status match a contact ID
      for (var contact in contactsProvider.userContacts) {
        if (status.viewerIds.contains(contact.phoneNumber)) {
          filteredContacts.add(contact);
        }
      }
    }
    for (var element in userModel.statusList) {
      // print(filteredContacts.length);
      stories.add(StoryItem(
          url: element.imageUrl,
          type: StoryItemType.image,
          statusModel: element,
          viewers: filteredContacts,
          duration: 8));
    }

    /// If story is video
    var story = stories[index];

    if (story.type == StoryItemType.video) {
      /// Dispose the previous _videoController (if any) before initializing new one.
      _videoController?.dispose();

      setState(() {
        _isVideoLoading = true; // Set loading to true when video starts loading
      });
      // Check if the URL is an asset or a network URL
      bool isAsset = story.url.startsWith('assets/');

      _videoController = isAsset
          ? VideoPlayerController.asset(story.url)
          : VideoPlayerController.networkUrl(Uri.parse(story.url));

      _videoController!
        ..initialize().then((_) {
          setState(() {
            _isVideoLoading = false;
            _isPaused = false;
          });
          _videoController!.play();

          // Limit video duration to 30 seconds
          if (_videoController!.value.duration.inSeconds > 30) {
            _videoController!.setLooping(false); // Disable looping
            Timer(const Duration(seconds: 30), () {
              _onAnimationCompleted();
              _videoController!.pause();
            });
          } else {
            _videoController!.setLooping(true); // Enable looping
          }

          Duration clampedDuration =
              _videoController!.value.duration.inSeconds > 30
                  ? const Duration(seconds: 30)
                  : _videoController!.value.duration;
          _startAnimation(index, duration: clampedDuration);
        });
    } else {
      _startAnimation(index); // Pass index without video duration
    }
  }

  void _startAnimation(int index, {Duration? duration}) {
    final UserModel userModel = Provider.of<UserModel>(context, listen: false);

    final ContactsProvider contactsProvider =
        Provider.of<ContactsProvider>(context, listen: false);
    print(userModel.firstName);
    List<StoryItem> stories = [];
    List<UserModel> filteredContacts = [];

    for (var status in userModel.statusList) {
      // Use the `any` method to check if any of the viewer IDs in the status match a contact ID
      for (var contact in contactsProvider.userContacts) {
        if (status.viewerIds.contains(contact.phoneNumber)) {
          filteredContacts.add(contact);
        }
      }
    }
    for (var element in userModel.statusList) {
      // print(filteredContacts.length);
      stories.add(StoryItem(
          url: element.imageUrl,
          type: StoryItemType.image,
          statusModel: element,
          viewers: filteredContacts,
          duration: 8));
    }
    Duration storyDuration =
        duration ?? Duration(seconds: stories[index].duration!);

    _animationController = AnimationController(
      vsync: this,
      duration: storyDuration,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController!)
      ..addListener(() {
        setState(() {
          _progress = _animation!.value;
        });
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _onAnimationCompleted();
        }
      });

    setState(() {
      _progress = 0.0; // Set progress to 0 before starting the animation
    });

    _animationController!.forward();
  }

  // Handles the completion of the story animation
  void _onAnimationCompleted() {
    final UserModel userModel = Provider.of<UserModel>(context, listen: false);

    final ContactsProvider contactsProvider =
        Provider.of<ContactsProvider>(context, listen: false);
    print(userModel.firstName);
    List<StoryItem> stories = [];
    List<UserModel> filteredContacts = [];

    for (var status in userModel.statusList) {
      // Use the `any` method to check if any of the viewer IDs in the status match a contact ID
      for (var contact in contactsProvider.userContacts) {
        if (status.viewerIds.contains(contact.phoneNumber)) {
          filteredContacts.add(contact);
        }
      }
    }
    for (var element in userModel.statusList) {
      // print(filteredContacts.length);
      stories.add(StoryItem(
          url: element.imageUrl,
          type: StoryItemType.image,
          statusModel: element,
          viewers: filteredContacts,
          duration: 8));
    }
    if (currentItemIndex == stories.length - 1) {
      widget.onComplete();
    } else {
      currentItemIndex++;
      widget.onPageChanged(currentItemIndex);
      setState(() {
        _progress =
            0.0; // Reset progress value to 0 when the story automatically advances
      });
      _playStory(currentItemIndex);
    }
  }

  // Handles tap action to go to the next story item
  void _onTapNext() {
    final UserModel userModel = Provider.of<UserModel>(context, listen: false);

    final ContactsProvider contactsProvider =
        Provider.of<ContactsProvider>(context, listen: false);
    print(userModel.firstName);
    List<StoryItem> stories = [];
    List<UserModel> filteredContacts = [];

    for (var status in userModel.statusList) {
      // Use the `any` method to check if any of the viewer IDs in the status match a contact ID
      for (var contact in contactsProvider.userContacts) {
        if (status.viewerIds.contains(contact.phoneNumber)) {
          filteredContacts.add(contact);
        }
      }
    }
    for (var element in userModel.statusList) {
      // print(filteredContacts.length);
      stories.add(StoryItem(
          url: element.imageUrl,
          type: StoryItemType.image,
          statusModel: element,
          viewers: filteredContacts,
          duration: 8));
    }
    // To prevent moving to the next story if the video is still loading
    if (_isVideoLoading) return;

    if (currentItemIndex == stories.length - 1) {
      widget.onComplete();
    } else {
      currentItemIndex++;
      widget.onPageChanged(currentItemIndex);
      _animationController!.dispose();
      setState(() {
        _progress = 0.0; // Reset progress value to 0 when tapping next
      });
      _playStory(currentItemIndex);
    }
  }

  // Handles tap action to go to the previous story item
  void _onTapPrevious() {
    if (currentItemIndex == 0) {
      // You can perform something here :)
    } else {
      currentItemIndex--;
      widget.onPageChanged(currentItemIndex);
      _animationController!.dispose();
      setState(() {
        _progress = 0.0; // Reset progress value to 0 when tapping next
      });
      _playStory(currentItemIndex);
    }
  }

  // Pause the story timer
  void _pauseTimer() {
    _animationController!.stop();
    _videoController?.pause();
    setState(() {});
  }

  // Resume the story timer
  void _resumeTimer() {
    _animationController!.forward();
    _videoController?.play();
    setState(() {});
  }

  // Dispose of the animation controller when the widget is disposed
  @override
  void dispose() {
    _animationController?.dispose();
    _timer?.cancel();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserModel userModel = Provider.of<UserModel>(context);

    final ContactsProvider contactsProvider =
        Provider.of<ContactsProvider>(context);
    print(userModel.firstName);
    List<StoryItem> stories = [];
    List<UserModel> filteredContacts = [];

    for (var status in userModel.statusList) {
      // Use the `any` method to check if any of the viewer IDs in the status match a contact ID
      for (var contact in contactsProvider.userContacts) {
        if (status.viewerIds.contains(contact.phoneNumber)) {
          filteredContacts.add(contact);
        }
      }
    }
    for (var element in userModel.statusList) {
      // print(filteredContacts.length);
      stories.add(StoryItem(
          url: element.imageUrl,
          type: StoryItemType.image,
          statusModel: element,
          viewers: filteredContacts,
          duration: 8));
    }
    return Container(
      color: Colors.black,
      child: GestureDetector(
        child: Stack(
          children: [
            /// All story items mapped in the Stack widget
            Stack(
              children: List.generate(
                stories.length,
                (index) {
                  var story = stories[index];
                  return Visibility(
                      visible: currentItemIndex == index,
                      maintainState: true,
                      child: _storyItem(story));
                },
              ),
            ),

            /// Story indicator which plays with timer, progress and total story Items
            /// check out widget in widgets dir.
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: widget.enableOnHoldHide == false
                  ? 1
                  : !_isPaused
                      ? 1
                      : 0,
              child: StoryIndicator(
                storyItemsLen: stories.length,
                currentItemIndex: currentItemIndex, // Add this
                progress: _progress,
                indicatorColor: widget.indicatorColor,
                indicatorHeight: widget.indicatorHeight,
                indicatorValueColor: widget.indicatorValueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Creates a single story item widget
  Widget _storyItem(StoryItem story) {
    final UserModel userModel = Provider.of<UserModel>(context);

    final ContactsProvider contactsProvider =
        Provider.of<ContactsProvider>(context);
    print(userModel.firstName);
    List<StoryItem> stories = [];
    List<UserModel> filteredContacts = [];

    for (var status in userModel.statusList) {
      // Use the `any` method to check if any of the viewer IDs in the status match a contact ID
      for (var contact in contactsProvider.userContacts) {
        if (status.viewerIds.contains(contact.phoneNumber)) {
          filteredContacts.add(contact);
        }
      }
    }
    for (var element in userModel.statusList) {
      // print(filteredContacts.length);
      stories.add(StoryItem(
          url: element.imageUrl,
          type: StoryItemType.image,
          statusModel: element,
          viewers: filteredContacts,
          duration: 8));
    }
    // print(widget.userInfo!.firstName);
    return Column(
      children: [
        AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: widget.enableOnHoldHide == false
              ? 1
              : !_isPaused
                  ? 1
                  : 0,
          child: Container(
            height: 100,
            padding: const EdgeInsets.only(left: 10, right: 10, top: 40),
            color: Colors.black,
            child: Column(
              children: [
                const SizedBox(
                  height: 5,
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                        onTap: widget.onComplete,
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        )),
                    const SizedBox(
                      width: 10,
                    ),
                    Container(
                      width: 45,
                      height: 45,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: CachedNetworkImage(
                            imageUrl: widget.userInfo!.imageUrl,
                            fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.userInfo!.firstName} ${widget.userInfo!.lastName}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(
                              height: 2,
                            ),
                            Text(
                              DateFormat.jm().format(DateTime.parse(widget
                                  .userInfo!
                                  .statusList[currentItemIndex]
                                  .timestamp)),
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                        onTap: widget.onMenuTapListener,
                        child: const Icon(
                          Icons.more_vert,
                          color: Colors.white,
                        ))
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            child: Stack(
              children: [
                Visibility(
                  visible: currentItemIndex == stories.indexOf(story) &&
                      story.type == StoryItemType.video &&
                      (_videoController == null ||
                          !_videoController!.value.isInitialized) &&
                      _isVideoLoading,
                  child: Container(
                    color: Colors.grey[600],
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.teal,
                      ),
                    ),
                  ),
                ),

                _switchStoryItemIsVideoOrImage(
                  story.url,
                  type: story.type,
                  controller: _videoController, // Pass the controller
                ),

                // Next story area
                Align(
                  alignment: Alignment.centerRight,
                  heightFactor: 1,
                  child: GestureDetector(
                    onTapDown: (details) {
                      _tapDownTime = DateTime.now();
                      _timer = Timer(const Duration(milliseconds: 200), () {
                        _timer = null;
                        if (_tapDownTime != null && _isVideoLoading == false) {
                          final elapsedTime = DateTime.now()
                              .difference(_tapDownTime!)
                              .inMilliseconds;
                          if (elapsedTime >= 200) {
                            setState(() => _isPaused = true);
                            _pauseTimer();
                          } else {
                            /// Do nothing if the onTapDown is tapped less than 200 milliseconds
                          }
                        }
                      });
                    },
                    onTapCancel: () {
                      _resumeTimer();
                      setState(() => _isPaused = false);
                    },
                    onTapUp: (details) {
                      if (_tapDownTime != null) {
                        final elapsedTime = DateTime.now()
                            .difference(_tapDownTime!)
                            .inMilliseconds;
                        if (elapsedTime > 200) {
                          _resumeTimer();
                          setState(() => _isPaused = false);
                        } else {
                          _onTapNext();
                        }
                        _tapDownTime = null;
                      }
                    },
                  ),
                ),

                // Previous story area
                Align(
                  alignment: Alignment.centerLeft,
                  heightFactor: 1,
                  child: SizedBox(
                    width: 70,
                    child: GestureDetector(
                      onTapDown: (details) {
                        _tapDownTime = DateTime.now();
                        _timer = Timer(const Duration(milliseconds: 200), () {
                          _timer = null;
                          if (_tapDownTime != null &&
                              _isVideoLoading == false) {
                            final elapsedTime = DateTime.now()
                                .difference(_tapDownTime!)
                                .inMilliseconds;
                            if (elapsedTime >= 200) {
                              setState(() => _isPaused = true);
                              _pauseTimer();
                            } else {
                              /// Do nothing if the onTapDown is tapped less than 200 milliseconds
                            }
                          }
                        });
                      },
                      onTapCancel: () {
                        _resumeTimer();
                        setState(() => _isPaused = false);
                      },
                      onTapUp: (details) {
                        if (_tapDownTime != null) {
                          final elapsedTime = DateTime.now()
                              .difference(_tapDownTime!)
                              .inMilliseconds;
                          if (elapsedTime > 200) {
                            _resumeTimer();
                            setState(() => _isPaused = false);
                          } else {
                            _onTapPrevious();
                          }
                          _tapDownTime = null;
                        }
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: widget.enableOnHoldHide == false
              ? 1
              : !_isPaused
                  ? 1
                  : 0,
          child: InkWell(
            onTap: () {
              setState(() => _isPaused = true);
              _pauseTimer();
              // showModalBottomSheet(context: context, builder: builder);
              Get.bottomSheet(_bottomSheet(story)).then((value) {
                _resumeTimer();
                setState(() => _isPaused = false);
              });
            },
            child: Container(
              height: 100,
              width: double.infinity,
              color: Colors.black,
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  Column(
                    children: [
                      const Icon(
                        Icons.keyboard_arrow_up,
                        color: Colors.white,
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        "",
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.remove_red_eye_outlined,
                        color: Colors.white,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        story.viewers!.length.toString(),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _bottomSheet(StoryItem storyItem) {
    final UserModel userModel = Provider.of<UserModel>(context, listen: false);

    final ContactsProvider contactsProvider =
        Provider.of<ContactsProvider>(context, listen: false);
    // print(userModel.firstName);
    List<StoryItem> stories = [];
    List<UserModel> filteredContacts = [];
    print(userModel.statusList.length);
    for (var status in userModel.statusList) {
      // Use the `any` method to check if any of the viewer IDs in the status match a contact ID
      for (var contact in contactsProvider.userContacts) {
        if (status.viewerIds.contains(contact.phoneNumber)) {
          filteredContacts.add(contact);
        }
      }
    }
    for (var element in userModel.statusList) {
      // print(filteredContacts.length);
      stories.add(StoryItem(
          url: element.imageUrl,
          type: StoryItemType.image,
          statusModel: element,
          viewers: filteredContacts,
          duration: 8));
    }
    AppColor app = AppColor();

    return Container(
      width: Get.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      height: 400,
      child: Column(
        children: [
          Container(
            height: 60,
            width: Get.width,
            padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
            decoration: BoxDecoration(
                color: app.changeColor(color: app.purpleColor),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                )),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    Row(
                      children: [
                        InkWell(
                          onTap: () {},
                          child: const Icon(
                            Icons.remove_red_eye_outlined,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          storyItem.viewers.length.toString(),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            StatusProvider().removeStatus(
                                stories[currentItemIndex].statusModel);
                            Navigator.pop(context);
                            _onTapNext();
                          },
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                for (var i = 0;
                    i < stories[currentItemIndex].viewers.length;
                    i++)
                  ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(200),
                      child: CachedNetworkImage(
                        imageUrl: stories[currentItemIndex].viewers[i].imageUrl,
                        height: 52,
                        width: 52,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      '${stories[currentItemIndex].viewers[i].firstName} ${stories[currentItemIndex].viewers[i].lastName}',
                      style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                    ),
                    subtitle: Text(
                      stories[currentItemIndex].viewers[i].bio,
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: app.changeColor(color: '797C7B')),
                    ),
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }

  _switchStoryItemIsVideoOrImage(
    String url, {
    required String type,
    VideoPlayerController? controller,
  }) {
    bool isAsset = url.startsWith('assets/');
    switch (type) {
      case StoryItemType.image:
        return StoryImage.url(url, isAsset: isAsset);
      case StoryItemType.video:
        return StoryVideo.url(url, controller);
    }
  }
}
