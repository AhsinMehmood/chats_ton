import 'dart:math';
import 'package:flutter/material.dart';

class StatusView extends StatelessWidget {
  final int numberOfStatus;
  final int indexOfSeenStatus;
  final double spacing;
  final double radius;
  final double padding;
  final String centerImageUrl;
  final double strokeWidth;
  final Color seenColor;
  final Color unSeenColor;

  StatusView(
      {this.numberOfStatus = 10,
      this.indexOfSeenStatus = 0,
      this.spacing = 10.0,
      this.radius = 50,
      this.padding = 5,
      required this.centerImageUrl,
      this.strokeWidth = 4,
      this.seenColor = Colors.grey,
      this.unSeenColor = Colors.blue})
      : assert(centerImageUrl != null, "Please provide centerImageUrl");

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: radius * 2,
            height: radius * 2,
            child: CustomPaint(
              painter: Arc(
                  alreadyWatch: indexOfSeenStatus,
                  numberOfArc: numberOfStatus,
                  spacing: spacing,
                  strokeWidth: strokeWidth,
                  seenColor: seenColor,
                  unSeenColor: unSeenColor),
            ),
          ),
          CircleAvatar(
            radius: radius - padding,
            backgroundImage: NetworkImage(centerImageUrl),
          ),
        ],
      ),
    );
  }
}

class Arc extends CustomPainter {
  final int numberOfArc;
  final int alreadyWatch;
  final double spacing;
  final double strokeWidth;
  final Color seenColor;
  final Color unSeenColor;
  Arc(
      {required this.numberOfArc,
      required this.alreadyWatch,
      required this.spacing,
      required this.strokeWidth,
      required this.seenColor,
      required this.unSeenColor});

  double doubleToAngle(double angle) => angle * pi / 180.0;

  void drawArcWithRadius(
      Canvas canvas,
      Offset center,
      double radius,
      double angle,
      Paint seenPaint,
      Paint unSeenPaint,
      double start,
      double spacing,
      int number,
      int alreadyWatch) {
    for (var i = 0; i < number; i++) {
      canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          doubleToAngle((start + ((angle + spacing) * i))),
          doubleToAngle(angle),
          false,
          alreadyWatch + 1 >= i ? seenPaint : unSeenPaint);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2.0, size.height / 2.0);
    final double radius = size.width / 2.0;
    double angle = numberOfArc == 1 ? 360.0 : (360.0 / numberOfArc - spacing);
    var startingAngle = 270.0;

    Paint seenPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..color = seenColor;

    Paint unSeenPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..color = unSeenColor;

    drawArcWithRadius(canvas, center, radius, angle, seenPaint, unSeenPaint,
        startingAngle, spacing, numberOfArc, alreadyWatch);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class StatusProgressPainter extends CustomPainter {
  final int statusLength;
  final bool
      currentUserInViewerList; // Boolean to check if the current user is in the viewer's list
  final double progress;
  final Color lineColor;

  StatusProgressPainter({
    required this.statusLength,
    required this.currentUserInViewerList,
    required this.progress,
    this.lineColor = Colors.blue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    if (currentUserInViewerList) {
      paint.color =
          Colors.green; // Color when the current user is in the viewer's list
    } else {
      paint.color = lineColor; // Default color
    }

    final double radius = size.width / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double sweepAngle = 2 * pi / statusLength;

    final startAngle = -pi / 2;
    final endAngle = startAngle + (2 * pi * progress);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      endAngle - startAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Always repaint when the data changes
  }
}

class StatusProgressIndicator extends StatelessWidget {
  final int statusLength;
  final double progress;
  final bool
      currentUserInViewerList; // Boolean to check if the current user is in the viewer's list

  StatusProgressIndicator({
    required this.statusLength,
    required this.progress,
    required this.currentUserInViewerList,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: StatusProgressPainter(
        statusLength: statusLength,
        currentUserInViewerList: currentUserInViewerList,
        progress: progress,
      ),
      child: SizedBox(
        width: 30.0, // Adjust the width as needed
        height: 30.0, // Adjust the height as needed
      ),
    );
  }
}
