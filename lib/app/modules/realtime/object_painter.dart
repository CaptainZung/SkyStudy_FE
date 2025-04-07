// import 'package:flutter/material.dart';

// class ObjectPainter extends CustomPainter {
//   final List<Map<String, dynamic>> objects;
//   final Size imageSize;

//   ObjectPainter({required this.objects, required this.imageSize});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.red
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 2;

//     final textStyle = TextStyle(
//       color: Colors.white,
//       fontSize: 14,
//       backgroundColor: Colors.black.withOpacity(0.5),
//     );

//     for (final obj in objects) {
//       final box = obj['box'];
//       if (box == null) continue;

//       final scaleX = size.width / imageSize.width;
//       final scaleY = size.height / imageSize.height;

//       final rect = Rect.fromLTRB(
//         box['x1'] * scaleX,
//         box['y1'] * scaleY,
//         box['x2'] * scaleX,
//         box['y2'] * scaleY,
//       );

//       // Draw bounding box
//       canvas.drawRect(rect, paint);

//       // Draw label
//       final textSpan = TextSpan(
//         text: '${obj['label_vi'] ?? obj['label']} (${(obj['confidence'] * 100).toStringAsFixed(1)}%)',
//         style: textStyle,
//       );
      
//       final textPainter = TextPainter(
//         text: textSpan,
//         textDirection: TextDirection.ltr,
//       )..layout();

//       textPainter.paint(
//         canvas,
//         Offset(rect.left, rect.top - textPainter.height),
//       );
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }