import 'package:chats_ton/Global/color.dart';
import 'package:chats_ton/Providers/conversation_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ShareContentSheet extends StatelessWidget {
  final String userId;
  final String secondUserId;
  final String chatId;
  const ShareContentSheet(
      {super.key,
      required this.userId,
      required this.secondUserId,
      required this.chatId});

  @override
  Widget build(BuildContext context) {
    AppColor appColor = AppColor();
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    Get.close(1);
                  },
                  child: const Icon(
                    Icons.close,
                  ),
                ),
                Text(
                  'Share Content',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            InkWell(
              onTap: () {
                ConversationProvider()
                    .sendImageMessage(userId, secondUserId, chatId);
              },
              child: Row(
                children: [
                  Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: appColor.changeColor(color: 'F2F8F7')),
                      child:
                          Center(child: SvgPicture.asset('assets/Camera.svg'))),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Camera',
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: appColor.changeColor(color: '000E08')),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Divider(
              height: 1,
              color: Colors.grey.shade400,
            ),
            // const SizedBox(
            //   height: 15,
            // ),
            // Row(
            //   children: [
            //     Container(
            //         padding: const EdgeInsets.all(10),
            //         decoration: BoxDecoration(
            //           color: appColor.changeColor(color: 'F2F8F7'),
            //           borderRadius: BorderRadius.circular(200),
            //         ),
            //         child: Center(child: SvgPicture.asset('assets/doc.svg'))),
            //     const SizedBox(
            //       width: 10,
            //     ),
            //     Column(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Text(
            //           'Documents',
            //           style: GoogleFonts.poppins(
            //               fontSize: 12,
            //               fontWeight: FontWeight.w500,
            //               color: appColor.changeColor(color: '000E08')),
            //         ),
            //         const SizedBox(
            //           height: 5,
            //         ),
            //         Text(
            //           'Share your files',
            //           style: GoogleFonts.poppins(
            //               fontSize: 10,
            //               fontWeight: FontWeight.w300,
            //               color: appColor.changeColor(color: '000E08')),
            //         ),
            //       ],
            //     ),
            //   ],
            // ),
            // const SizedBox(
            //   height: 10,
            // ),
            // // Divider(
            // //   height: 1,
            // //   color: Colors.grey.shade400,
            // // ),
            // // const SizedBox(
            // //   height: 15,
            // // ),
            // // Row(
            // //   children: [
            // //     Container(
            // //         padding: const EdgeInsets.all(10),
            // //         decoration: BoxDecoration(
            // //           color: appColor.changeColor(color: 'F2F8F7'),
            // //           borderRadius: BorderRadius.circular(200),
            // //         ),
            // //         child: Center(child: SvgPicture.asset('assets/Chart.svg'))),
            // //     // const SizedBox(
            // //     //   width: 10,
            // //     // ),
            // //     // Column(
            // //     //   mainAxisAlignment: MainAxisAlignment.center,
            // //     //   crossAxisAlignment: CrossAxisAlignment.start,
            // //     //   children: [
            // //     //     Text(
            // //     //       'Create a poll',
            // //     //       style: GoogleFonts.poppins(
            // //     //           fontSize: 12,
            // //     //           fontWeight: FontWeight.w500,
            // //     //           color: appColor.changeColor(color: '000E08')),
            // //     //     ),
            // //     //     const SizedBox(
            // //     //       height: 5,
            // //     //     ),
            // //     //     Text(
            // //     //       'Create poll for any query',
            // //     //       style: GoogleFonts.poppins(
            // //     //           fontSize: 10,
            // //     //           fontWeight: FontWeight.w300,
            // //     //           color: appColor.changeColor(color: '000E08')),
            // //     //     ),
            // //     //   ],
            // //     // ),
            // //   ],
            // // ),

            Divider(
              height: 1,
              color: Colors.grey.shade400,
            ),
            const SizedBox(
              height: 15,
            ),
            InkWell(
              onTap: () {
                ConversationProvider()
                    .sendMediaMessage(userId, secondUserId, chatId);
                Get.back();
              },
              child: Row(
                children: [
                  Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: appColor.changeColor(color: 'F2F8F7'),
                        borderRadius: BorderRadius.circular(200),
                      ),
                      child:
                          Center(child: SvgPicture.asset('assets/media.svg'))),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Media',
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: appColor.changeColor(color: '000E08')),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Share photos and videos',
                        style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w300,
                            color: appColor.changeColor(color: '000E08')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            // Divider(
            //   height: 1,
            //   color: Colors.grey.shade400,
            // ),
            // const SizedBox(
            //   height: 15,
            // ),
            // Row(
            //   children: [
            //     Container(
            //         padding: const EdgeInsets.all(10),
            //         decoration: BoxDecoration(
            //           color: appColor.changeColor(color: 'F2F8F7'),
            //           borderRadius: BorderRadius.circular(200),
            //         ),
            //         child: Center(child: SvgPicture.asset('assets/user.svg'))),
            //     const SizedBox(
            //       width: 10,
            //     ),
            //     Column(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Text(
            //           'Contact',
            //           style: GoogleFonts.poppins(
            //               fontSize: 12,
            //               fontWeight: FontWeight.w500,
            //               color: appColor.changeColor(color: '000E08')),
            //         ),
            //         const SizedBox(
            //           height: 5,
            //         ),
            //         Text(
            //           'Share your contacts',
            //           style: GoogleFonts.poppins(
            //               fontSize: 10,
            //               fontWeight: FontWeight.w300,
            //               color: appColor.changeColor(color: '000E08')),
            //         ),
            //       ],
            //     ),
            //   ],
            // ),
            // const SizedBox(
            //   height: 10,
            // ),
            // Divider(
            //   height: 1,
            //   color: Colors.grey.shade400,
            // ),
            // const SizedBox(
            //   height: 15,
            // ),
            // Row(
            //   children: [
            //     Container(
            //         padding: const EdgeInsets.all(10),
            //         decoration: BoxDecoration(
            //           color: appColor.changeColor(color: 'F2F8F7'),
            //           borderRadius: BorderRadius.circular(200),
            //         ),
            //         child: Center(
            //           child: Icon(
            //             Icons.location_on_outlined,
            //             color: appColor.changeColor(color: '797C7B'),
            //           ),
            //         )),
            //     const SizedBox(
            //       width: 10,
            //     ),
            //     Column(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Text(
            //           'Location',
            //           style: GoogleFonts.poppins(
            //               fontSize: 12,
            //               fontWeight: FontWeight.w500,
            //               color: appColor.changeColor(color: '000E08')),
            //         ),
            //         const SizedBox(
            //           height: 5,
            //         ),
            //         Text(
            //           'Share your location',
            //           style: GoogleFonts.poppins(
            //               fontSize: 10,
            //               fontWeight: FontWeight.w300,
            //               color: appColor.changeColor(color: '000E08')),
            //         ),
            //       ],
            //     ),
            //   ],
            // ),
            // const SizedBox(
            //   height: 10,
            // ),
            // Divider(
            //   height: 1,
            //   color: Colors.grey.shade400,
            // ),
            // const SizedBox(
            //   height: 20,
            // ),
          ],
        ),
      ),
    );
  }
}
