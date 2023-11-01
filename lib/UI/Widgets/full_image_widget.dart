import 'package:cached_network_image/cached_network_image.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';

class FullImageWidget extends StatelessWidget {
  final String imageUrl;
  const FullImageWidget({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.close,
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: FastCachedImage(
          url: imageUrl,
          // fit: BoxFit.cover,
          // height: Get,
          // width: 245,
          fadeInDuration: const Duration(milliseconds: 200),
          errorBuilder: (context, exception, stacktrace) {
            return Text(stacktrace.toString());
          },
          loadingBuilder: (context, progress) {
            return Center(
              child: SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 2,
                      value: progress.progressPercentage.value)),
            );
          },
        ),
      ),
    );
  }
}
